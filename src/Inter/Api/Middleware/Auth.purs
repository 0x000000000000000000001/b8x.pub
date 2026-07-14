module Inter.Api.Middleware.Auth where

import Proem

import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig)
import Control.Alt ((<|>))
import Core.Mod.Trace.Subject (Subject(..))
import Core.Mod.User.Id.Id (UserId)
import Foreign (Foreign)
import Yoga.JSON (readImpl)
import Control.Monad.Except (runExcept, ExceptT)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..))
import Data.Array as Array
import Data.String as String
import Effect.Aff (Aff, try)
import Control.Monad.Error.Class (throwError)
import Effect.Exception (error)
import Foreign.Object as Object
import Node.HTTP.IncomingMessage as IncomingMessage
import Node.HTTP.Types (IMServer, IncomingMessage)
import Util.Crypto.Paseto.Paseto (decryptV3Local)
import Util.Cookie.Cookie as Cookie
import Inter.Api.ApiM (Context)
import Util.Crawler (looksLikeCrawler)

getSubject :: Context -> IncomingMessage IMServer -> Aff Subject
getSubject ctx req = do
  let rawIp = Object.lookup "x-forwarded-for" (IncomingMessage.headers req)
  -- The x-forwarded-for header can contain a comma-separated list of IPs (client, proxy1, proxy2).
  -- We extract the first IP (left-most), which represents the original client.
  let ip = rawIp >>= (String.split (String.Pattern ",") ▷ Array.head) <#> String.trim
  let agent = Object.lookup "user-agent" (IncomingMessage.headers req)

  let xAppId = Object.lookup "x-app-id" (IncomingMessage.headers req)
  let isHuman = xAppId == Just publicConfig.ui.appId
  let isMigration = xAppId == Just "InitialMigration"

  let
    isBot = case agent of
      Just a -> looksLikeCrawler a
      Nothing -> false

  if isBot then
    η $ InternetCrawler { ip, agent }
  else if isMigration then
    η $ InitialMigration { ip, agent }
  else if isHuman then do
    mUserId <- extractUserId ctx req
    case mUserId of
      Just uid -> η $ IdentifiedUiHuman { ip, agent, userId: uid }
      Nothing -> η $ AnonymousUiHuman { ip, agent }
  else
    case xAppId of
      Nothing -> throwError (error "Missing X-App-Id")
      Just v -> throwError (error ("Invalid or refused X-App-Id: " <> show v <> " (expected: " <> show publicConfig.ui.appId <> ")"))

data TokenSource = FromHeader | FromCookie

derive instance Eq TokenSource

extractUserId :: Context -> IncomingMessage IMServer -> Aff (Maybe UserId)
extractUserId _ req = do
  let extracted = extractToken req
  let
    checkTraceAndFail = do
      let cookieHeader = Object.lookup "cookie" (IncomingMessage.headers req)
      let parsedCookies = Cookie.parse (cookieHeader ??⇒ "")
      case Object.lookup "refresh_token_trace" parsedCookies of
        Just _ -> throwError (error "Token expired")
        Nothing -> η Nothing

  case extracted of
    Nothing -> checkTraceAndFail
    Just { source, token } -> do
      let pasetoKey = internalConfig.auth.pasetoLocalKey
      decryptResult <- try $ decryptV3Local pasetoKey token
      case decryptResult of
        Left _ -> checkTraceAndFail
        Right jsonPayload -> do
          case runExcept (readImpl jsonPayload :: ExceptT _ _ (Object.Object Foreign)) of
            Right obj -> do
              -- CSRF Check
              let method = IncomingMessage.method req
              let isMutation = method == "POST" || method == "PUT" || method == "DELETE" || method == "PATCH"
              when (isMutation && source == FromCookie) do
                let expectedCsrfToken = Object.lookup "csrfToken" obj >>= readImpl ▷ runExcept ▷ either (const Nothing) Just
                let actualCsrfToken = Object.lookup "x-csrf-token" (IncomingMessage.headers req)
                case expectedCsrfToken, actualCsrfToken of
                  Just expected, Just actual | expected == actual -> pure unit
                  _, _ -> throwError (error "Invalid or missing CSRF token")

              case Object.lookup "userId" obj of
                Just userIdJson -> case runExcept (readImpl userIdJson) :: Either _ UserId of
                  Right uid -> do
                    let mIat = Object.lookup "iat" obj >>= readImpl ▷ runExcept ▷ either (const Nothing) Just
                    case mIat of
                      Just (_ :: String) -> η (Just uid)
                      Nothing -> η (Just uid)
                  _ -> checkTraceAndFail
                Nothing -> checkTraceAndFail
            Left _ -> checkTraceAndFail

extractToken :: IncomingMessage IMServer -> Maybe { source :: TokenSource, token :: String }
extractToken req =
  ({ source: FromHeader, token: _ } <$> extractFromBearer req)
    <|> ({ source: FromCookie, token: _ } <$> extractFromCookie req)

extractFromBearer :: IncomingMessage IMServer -> Maybe String
extractFromBearer req = do
  authHeader <- Object.lookup "authorization" (IncomingMessage.headers req)
  let authHeaderLower = String.toLower authHeader
  if String.indexOf (String.Pattern "bearer ") authHeaderLower == Just 0 then Just (String.trim (String.drop 7 authHeader))
  else Nothing

extractFromCookie :: IncomingMessage IMServer -> Maybe String
extractFromCookie req = do
  cookieHeader <- Object.lookup "cookie" (IncomingMessage.headers req)
  let parsedCookies = Cookie.parse cookieHeader
  Object.lookup "session" parsedCookies
