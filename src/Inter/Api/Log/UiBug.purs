module Inter.Api.Log.UiBug where

import Proem

import Data.Either (Either(..))
import Effect.Aff (Aff, launchAff_, try)
import Effect.Console as Console
import Foreign as Foreign
import Foreign.Index (readProp)
import Foreign.Object as Object
import Inter.Api.ApiM (Context, runApiM)
import Node.HTTP.IncomingMessage as IncomingMessage
import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig)
import Util.Env (Env(..))
import Node.HTTP.Types (IMServer, ServerResponse, IncomingMessage)
import Util.Foreign.Native as Util.Foreign.Native
import Yoga.JSON as Yoga.JSON
import Control.Alt ((<|>))
import Data.String (Pattern(..), contains)
import Data.String.Common (toLower)
import Data.Maybe (Maybe(..), fromMaybe)
import Control.Monad.Except (runExcept)
import Inter.Api.Registry (readBody, respondUnknown)
import Effect (Effect)
import Node.HTTP.ServerResponse (setStatusCode, toOutgoingMessage)
import Node.HTTP.OutgoingMessage (setHeader, toWriteable)
import Node.Stream (end, writeString)
import Node.Encoding (Encoding(..))
import Infra.Client.Aws.Ses.Ses as Ses
import Core.Mod.Trace.Cause (CauseNode(Query))
import Core.Mod.Id.Id as Id
import Core.Mod.Trace.Subject (Subject(..))

sendResponse :: Int -> String -> ServerResponse -> Effect Ɩ
sendResponse statusCode body res = do
  setStatusCode statusCode res
  let msg = toOutgoingMessage res
  setHeader "Content-Type" "application/json" msg
  ø $ writeString (toWriteable msg) UTF8 body
  end (toWriteable msg)

newtype LogUiBugPayload = LogUiBugPayload
  { url :: String
  , error :: String
  , userAgent :: Maybe String
  }

readPropOpt :: forall a. Yoga.JSON.ReadForeign a => String -> Foreign.Foreign -> Foreign.F (Maybe a)
readPropOpt prop obj =
  case runExcept (readProp prop obj) of
    Left _ -> pure Nothing
    Right val -> if Foreign.isUndefined val then pure Nothing else map Just (Yoga.JSON.readImpl val)

instance Yoga.JSON.ReadForeign LogUiBugPayload where
  readImpl json = do
    obj <- Yoga.JSON.readImpl json :: Foreign.F (Object.Object Foreign.Foreign)
    
    urlForeign <- readProp "url" (Foreign.unsafeToForeign obj)
    url <- Yoga.JSON.readImpl urlForeign
    
    errorForeign <- readProp "error" (Foreign.unsafeToForeign obj)
    errorStr <- Yoga.JSON.readImpl errorForeign
    
    userAgent <- readPropOpt "userAgent" (Foreign.unsafeToForeign obj)

    pure (LogUiBugPayload { url, error: errorStr, userAgent })


handleLogUiBug :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleLogUiBug ctx req res = do
  bodyStr <- readBody req

  case Util.Foreign.Native.parseJSON bodyStr of
    Left e -> do
      ʌ $ Console.error $ "LogUiBug [Parse Error]: " <> e <> "\nPayload: " <> bodyStr
      respondUnknown req res "Parse Error"
    Right jsonPayload -> case runExcept (Yoga.JSON.readImpl jsonPayload) of
      Left _ -> do
        ʌ $ Console.error $ "LogUiBug [Decode Error]: \nPayload: " <> bodyStr
        respondUnknown req res "Decode Error"
      Right (LogUiBugPayload payload) -> do
        runId <- ʌ Id.generate
        let
          ip = Object.lookup "x-forwarded-for" (IncomingMessage.headers req)
          agent = payload.userAgent <|> Object.lookup "user-agent" (IncomingMessage.headers req)
          agentLower = toLower (fromMaybe "" agent)
          isBot = contains (Pattern "bot") agentLower || contains (Pattern "spider") agentLower || contains (Pattern "crawl") agentLower || contains (Pattern "googleother") agentLower
          subject = Just $ ThirdPartyWebhook { thirdParty: "Frontend Telemetry", ip, agent }
          cause = { run: runId, append: Nothing, cause: Just (Query { run: runId, subject, name: "LogUiBug" }), overriddenAt: Nothing }
        
        if isBot then do
          ʌ $ Console.log $ "[LogUiBug] Dropped frontend error from bot: " <> payload.url
          ʌ $ sendResponse 204 "" res
        else do
          -- Fire and forget the email sending in background
          ʌ $ launchAff_ $ do
            ʌ $ Console.log $ "[LogUiBug] Received frontend error from URL: " <> payload.url
            let
              html = "<h2>Frontend Error Report</h2><p><b>URL:</b> " <> payload.url <> "</p><p><b>Error:</b></p><pre>" <> payload.error <> "</pre><p><b>User-Agent:</b> " <> fromMaybe "Unknown" agent <> "</p>"
              text = "Frontend Error Report\n\nURL: " <> payload.url <> "\nError: " <> payload.error <> "\nUser-Agent: " <> fromMaybe "Unknown" agent
              mailOpt =
                { to: { email: internalConfig.mail.to.bug, name: "Kévin" }
                , subject: "[b8x] [bug] [prod] UI error on " <> payload.url
                , html
                , text
                }
            
            case publicConfig.env of
              Dev -> ʌ $ Console.log $ "[LogUiBug] Skipped sending email to " <> internalConfig.mail.to.bug <> " because env == Dev"
              Prod -> do
                mailRes <- try $ runApiM ctx cause $ Ses.sendBugMail mailOpt
                ʌ $ case mailRes of
                  Left err -> Console.error $ "[LogUiBug] Failed to send email (Aff error): " <> show err
                  Right (Left _) -> Console.error $ "[LogUiBug] Failed to send email (LogicException)"
                  Right (Right _) -> Console.log $ "[LogUiBug] Email successfully sent to " <> internalConfig.mail.to.bug
          
          ʌ $ sendResponse 204 "" res
