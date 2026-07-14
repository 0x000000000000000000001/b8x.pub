module Inter.Api.Webhook.HelloAsso where

import Proem

import Core.Feat.Membership.Message.Command.TrackUserDonated.Command (TrackUserDonated)
import Core.Message.Command.Handle.Handle (handleCommand)
import Core.Message.Command.Make (makeCommand)
import Core.Message.MakeMessageM (liftMakeMessageM)
import Core.Mod.Email.Email as Email
import Core.Mod.Id.Id as Id
import Core.Mod.Time.Instant as Instant
import Core.Mod.Trace.Cause (CauseNode(Command))
import Yoga.JSON (class ReadForeign, writeImpl)
import Foreign.Index (readProp)
import Control.Monad.Except (runExcept)
import Data.DateTime.Instant (instant) as Base
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, try)
import Effect.Console as Console
import Foreign.Object as Object
import Inter.Api.ApiM (Context, runApiM)
import Node.HTTP.OutgoingMessage (setHeader, toWriteable)
import Node.HTTP.ServerResponse (setStatusCode, toOutgoingMessage)
import Node.HTTP.Types (IMServer, ServerResponse, IncomingMessage)
import Node.HTTP.IncomingMessage as IncomingMessage
import Core.Mod.Trace.Subject (Subject(..))
import Node.Stream (end, writeString)
import Node.Encoding (Encoding(..))
import Inter.Api.Registry (readBody, respondUnknown)
import Config.InternalConfig (internalConfig)

import Foreign as Foreign
import Util.Foreign.Native as Util.Foreign.Native
import Data.Array as Array
import Data.Newtype as Data.Newtype
import Yoga.JSON as Yoga.JSON
import Foreign.Object as Foreign.Object
sendResponse :: Int -> String -> ServerResponse -> Effect Ɩ
sendResponse statusCode body res = do
  setStatusCode statusCode res
  let msg = toOutgoingMessage res
  setHeader "Content-Type" "application/json" msg
  ø $ writeString (toWriteable msg) UTF8 body
  end (toWriteable msg)

newtype HelloAssoWebhookPayload = HelloAssoWebhookPayload
  { eventType :: String
  , data :: HelloAssoWebhookData
  }

newtype HelloAssoWebhookData = HelloAssoWebhookData
  { state :: Maybe String
  , date :: Maybe String
  , email :: Maybe String
  , amount :: Int
  }

readPropOpt :: forall a. Yoga.JSON.ReadForeign a => String -> Foreign.Foreign -> Foreign.F (Maybe a)
readPropOpt prop obj =
  case runExcept (readProp prop obj) of
    Left _ -> pure Nothing
    Right val -> if Foreign.isUndefined val then pure Nothing else map Just (Yoga.JSON.readImpl val)
instance ReadForeign HelloAssoWebhookPayload where
  readImpl json = do
    obj <- Yoga.JSON.readImpl json :: Foreign.F (Foreign.Object.Object Foreign.Foreign)
    
    eventTypeForeign <- readProp "eventType" (Foreign.unsafeToForeign obj)
    eventType <- Yoga.JSON.readImpl eventTypeForeign
    
    dataObjForeign <- readProp "data" (Foreign.unsafeToForeign obj)
    dataObj <- Yoga.JSON.readImpl dataObjForeign :: Foreign.F (Foreign.Object.Object Foreign.Foreign)

    state <- readPropOpt "state" (Foreign.unsafeToForeign dataObj)
    date <- readPropOpt "date" (Foreign.unsafeToForeign dataObj)
    
    amountForeign <- readProp "amount" (Foreign.unsafeToForeign dataObj)
    amount <- Yoga.JSON.readImpl amountForeign
    
    payerForeignResult <- pure (runExcept (readProp "payer" (Foreign.unsafeToForeign dataObj)))
    email <- case payerForeignResult of
      Left _ -> pure Nothing
      Right payerForeign -> if Foreign.isUndefined payerForeign then pure Nothing else do
        payer <- Yoga.JSON.readImpl payerForeign :: Foreign.F (Foreign.Object.Object Foreign.Foreign)
        readPropOpt "email" (Foreign.unsafeToForeign payer)

    pure (HelloAssoWebhookPayload { eventType, data: HelloAssoWebhookData { state, date, email, amount } })
handleWebhookHelloAsso :: Maybe String -> Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleWebhookHelloAsso mSecret ctx req res = do
  bodyStr <- readBody req

  if mSecret /= Just internalConfig.helloAsso.webhookSecret then do
    ʌ $ Console.error $ "HelloAsso Webhook [Invalid Secret]: got " <> show mSecret
    ʌ $ sendResponse 401 "Invalid secret" res
  else case Util.Foreign.Native.parseJSON bodyStr of
    Left e -> do
      ʌ $ Console.error $ "HelloAsso Webhook [Parse Error]: " <> e <> "\nPayload: " <> bodyStr
      respondUnknown req res "Parse Error"
    Right jsonPayload -> case runExcept (Yoga.JSON.readImpl jsonPayload) of
      Left e -> do
        ʌ $ Console.error $ "HelloAsso Webhook [Decode Error]: " <> Array.intercalate ", " (Array.fromFoldable (map Foreign.renderForeignError (Data.Newtype.unwrap e))) <> "\nPayload: " <> bodyStr
        respondUnknown req res "Decode Error"
      Right (HelloAssoWebhookPayload { eventType, data: HelloAssoWebhookData { state, date, email, amount } }) -> do
        if eventType == "Payment" && state == Just "Authorized" then do
          case email of
            Nothing -> do
              ʌ $ Console.error $ "HelloAsso Webhook [Missing Email]: \nPayload: " <> bodyStr
              respondUnknown req res "Missing email"
            Just emailStr -> case Email.make_ true emailStr of
              Left _ -> do
                ʌ $ Console.error $ "HelloAsso Webhook [Invalid Email]: " <> emailStr <> "\nPayload: " <> bodyStr
                respondUnknown req res "Invalid email"
              Right validEmail -> case date of
                Nothing -> do
                  ʌ $ Console.error $ "HelloAsso Webhook [Missing Date]: \nPayload: " <> bodyStr
                  respondUnknown req res "Missing date"
                Just dateStr -> case Instant.parseIsoString dateStr of
                  Nothing -> do
                    ʌ $ Console.error $ "HelloAsso Webhook [Invalid Date Format]: " <> dateStr <> "\nPayload: " <> bodyStr
                    respondUnknown req res "Invalid date format"
                  Just numDate -> case Base.instant (Milliseconds numDate) of
                    Nothing -> do
                      ʌ $ Console.error $ "HelloAsso Webhook [Invalid Instant Bounds]: " <> dateStr <> "\nPayload: " <> bodyStr
                      respondUnknown req res "Invalid instant bounds"
                    Just validInstant -> do
                      runId <- ʌ Id.generate
                      let
                        subject = Just $ ThirdPartyWebhook
                          { thirdParty: "HelloAsso"
                          , ip: Object.lookup "x-forwarded-for" (IncomingMessage.headers req)
                          , agent: Object.lookup "user-agent" (IncomingMessage.headers req)
                          }
                      let cause = { run: runId, append: Nothing, cause: Just (Command { run: runId, subject, name: "WebhookHelloAsso", cause: Nothing }), overriddenAt: Nothing }

                      cmdResult <- try $ runApiM ctx cause $ do
                        let finalPayload = [ Tuple "email" (writeImpl validEmail), Tuple "donatedAt" (writeImpl (Instant.Instant validInstant)), Tuple "amount" (writeImpl amount) ]
                        cmd <- liftMakeMessageM (makeCommand @TrackUserDonated (Object.fromFoldable finalPayload))
                        handleCommand @TrackUserDonated true cmd

                      case cmdResult of
                        Left _ -> do
                          ʌ $ Console.error $ "HelloAsso Webhook [Command Failed]: TrackUserDonated \nPayload: " <> bodyStr
                          respondUnknown req res "Internal Error"
                        Right _ -> do
                          ʌ $ Console.log $ "HelloAsso Webhook [Success]: Tracked donation"
                          ʌ $ sendResponse 200 "OK" res
        else do
          ʌ $ Console.log $ "HelloAsso Webhook [Ignored]: eventType=" <> eventType
          ʌ $ sendResponse 200 "OK" res
