module Inter.Api.Membership.Auth where
import Util.Foreign.Native as Util.Foreign.Native
import Foreign as Foreign
import Data.Array as Array
import Data.Newtype as Data.Newtype

import Proem

import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig)
import Core.Feat.Membership.Message.Command.SendMeMagicLink.Command (SendMeMagicLink)
import Core.Feat.Membership.Message.Command.ConsumeMagicLink.Command (ConsumeMagicLink)
import Core.Mod.Email.Email (Email)
import Core.Mod.User.Id.Id (UserId)
import Core.Mod.Trace.Cause (CauseNode(Command))
import Yoga.JSON (class WriteForeign, E, readImpl, writeImpl, unsafeStringify)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Core.Mod.Id.Id as Id
import Data.Tuple (Tuple(..))
import Data.UUID (genUUID)
import Data.UUID as UUID
import Effect.Exception (message)
import Effect (Effect)
import Effect.Aff (Aff, try)
import Core.Feat.Effect.Cache as Cache
import Core.Message.Command.Make (makeCommand)
import Core.Message.Command.Handle.Handle (handleCommand)
import Core.Message.Query.Handle (handleQuery)
import Core.Message.Query.Make (makeQuery)
import Core.Message.MakeMessageM (liftMakeMessageM)
import Core.Feat.Membership.Message.Query.GetUserAccount.Query (GetUserAccount)
import Core.Mod.User.Id.Message.Field.TargetUser (TargetUser(..))
import Core.Feat.Membership.Message.Query.GetUserAccount.Field.Needs (Needs(..))
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result as QueryResult
import Core.Mod.User.Auth.Constant (refreshTokenTtlSec)
import Data.Variant as Variant
import Data.Newtype (unwrap)
import Foreign.Object as Object
import Inter.Api.ApiM (Context, runApiM)
import Inter.Api.Middleware.Auth (getSubject)
import Inter.Api.Registry (readBody, respondUnknown, respondUnauthorized)
import Node.Encoding (Encoding(..))
import Node.HTTP.IncomingMessage as IncomingMessage
import Node.HTTP.OutgoingMessage (setHeader, toWriteable)
import Node.HTTP.ServerResponse (setStatusCode, toOutgoingMessage)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse, OutgoingMessage)
import Node.Stream (end, writeString)
import Util.Crypto.Paseto.Paseto (encryptV3Local)
import Util.Cookie.Cookie as Cookie
import Util.I18n (Language(..), translate)

foreign import appendHeaderImpl :: String -> String -> OutgoingMessage -> Effect Unit

appendHeader :: String -> String -> OutgoingMessage -> Effect Unit
appendHeader = appendHeaderImpl

foreign import nowIso :: Effect String

type MagicLinkRequestPayload = { email :: String, returnTo :: Maybe String }

handleRequestMagicLink :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleRequestMagicLink ctx req res = do
  bodyStr <- readBody req
  case Util.Foreign.Native.parseJSON bodyStr of
    Left e -> respondUnknown req res e
    Right jsonPayload -> case (runExcept (readImpl jsonPayload) :: E _) of
      Left e -> respondUnknown req res (Array.intercalate ", " (Array.fromFoldable (map Foreign.renderForeignError (Data.Newtype.unwrap e))))
      Right (payload :: MagicLinkRequestPayload) -> do
        runId <- ʌ Id.generate

        mSubject <- try $ getSubject ctx req
        let
          subject = case mSubject of
            Left _ -> Nothing
            Right s -> Just s

        let cause = { run: runId, append: Nothing, cause: Just (Command { run: runId, subject, name: "SendMeMagicLink", cause: Nothing }), overriddenAt: Nothing }

        cmdResult <- try $ runApiM ctx cause $ do
          cmd <- liftMakeMessageM (makeCommand @SendMeMagicLink (Object.fromFoldable [ Tuple "email" (writeImpl payload.email), Tuple "returnTo" (writeImpl (payload.returnTo ??⇒ "/")) ]))
          handleCommand @SendMeMagicLink true cmd

        case cmdResult of
          Left err -> respondUnknown req res (message err)
          Right (Left err) -> respondUnknown req res (translate En err)
          Right (Right _) -> do
            let responseString = unsafeStringify $ writeImpl { success: true }
            ʌ do
              setStatusCode 200 res
              let msg = toOutgoingMessage res
              setHeader "Content-Type" "application/json" msg
              _ <- writeString (toWriteable msg) UTF8 responseString
              end (toWriteable msg)

type ConsumeMagicLinkPayload = { token :: String }

handleConsumeMagicLink :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleConsumeMagicLink ctx req res = do
  bodyStr <- readBody req
  case Util.Foreign.Native.parseJSON bodyStr of
    Left e -> respondUnknown req res e
    Right jsonPayload -> case (runExcept (readImpl jsonPayload) :: E _) of
      Left e -> respondUnknown req res (Array.intercalate ", " (Array.fromFoldable (map Foreign.renderForeignError (Data.Newtype.unwrap e))))
      Right (payload :: ConsumeMagicLinkPayload) -> do
        runId <- ʌ Id.generate

        mSubject <- try $ getSubject ctx req
        let
          subject = case mSubject of
            Left _ -> Nothing
            Right s -> Just s

        let cause = { run: runId, append: Nothing, cause: Just (Command { run: runId, subject, name: "ConsumeMagicLink", cause: Nothing }), overriddenAt: Nothing }

        cmdResult <- try $ runApiM ctx cause $ do
          cmd <- liftMakeMessageM (makeCommand @ConsumeMagicLink (Object.fromFoldable [ Tuple "token" (writeImpl payload.token) ]))
          handleCommand @ConsumeMagicLink true cmd

        case cmdResult of
          Left _ -> respondUnauthorized req res "Invalid or expired token"
          Right (Left err) -> case Variant.prj (π @"Core.Mod.User.MagicLink.Token.Exception.AlreadyLoggedInSameUser") (unwrap err) of
            Just _ -> sendJsonResponse res 409 { success: false, error: "ALREADY_LOGGED_IN_SAME_USER" }
            Nothing -> respondUnauthorized req res "Invalid or expired token"
          Right (Right { userId, email }) -> do
            let pasetoKey = internalConfig.auth.pasetoLocalKey
            csrfUuid <- ʌ genUUID
            let csrfToken = UUID.toString csrfUuid
            pasetoToken <- encryptV3Local pasetoKey (writeImpl { userId: userId, csrfToken: csrfToken }) "5m"

            refreshUuid <- ʌ genUUID
            let refreshToken = UUID.toString refreshUuid
            let refreshCacheKey = Cache.cacheKey "refresh_token" refreshToken "" (Nothing :: Maybe Foreign.Foreign)
            _ <- try $ runApiM ctx cause $ Cache.set refreshCacheKey refreshTokenTtlSec { userId, email }

            accountRes <- try $ runApiM ctx cause $ do
              query <- liftMakeMessageM (makeQuery @GetUserAccount (Object.fromFoldable [ Tuple "user" (writeImpl (ById userId)), Tuple "needs" (writeImpl (Needs { adFree: Needed ι ι, hasPaidLastYear: Needed ι ι })) ]))
              handleQuery @GetUserAccount query

            let
              { adFree, hasPaidLastYear } = case accountRes of
                Right (Right { adFree: QueryResult.Given adFree', hasPaidLastYear: QueryResult.Given hasPaidLastYear' }) -> { adFree: adFree', hasPaidLastYear: hasPaidLastYear' }
                _ -> { adFree: false, hasPaidLastYear: false }

            ʌ do
              setStatusCode 200 res
              let msg = toOutgoingMessage res
              setHeader "Content-Type" "application/json" msg
              let
                cookieStr = Cookie.serialize "session" pasetoToken
                  { maxAge: 900
                  , httpOnly: true
                  , path: "/"
                  , secure: true
                  , sameSite: "lax"
                  , domain: publicConfig.ui.host
                  }
              let
                traceCookieStr = Cookie.serialize "session_trace" "1"
                  { maxAge: 900
                  , httpOnly: false
                  , path: "/"
                  , secure: true
                  , sameSite: "lax"
                  , domain: publicConfig.ui.host
                  }
              let
                csrfCookieStr = Cookie.serialize "csrf_token" csrfToken
                  { maxAge: 900
                  , httpOnly: false
                  , path: "/"
                  , secure: true
                  , sameSite: "lax"
                  , domain: publicConfig.ui.host
                  }
              let
                refreshCookieStr = Cookie.serialize "refresh_token" refreshToken
                  { maxAge: refreshTokenTtlSec
                  , httpOnly: true
                  , path: "/api/auth/refresh"
                  , secure: true
                  , sameSite: "lax"
                  , domain: publicConfig.ui.host
                  }
              let
                refreshTraceCookieStr = Cookie.serialize "refresh_token_trace" "1"
                  { maxAge: refreshTokenTtlSec
                  , httpOnly: false
                  , path: "/"
                  , secure: true
                  , sameSite: "lax"
                  , domain: publicConfig.ui.host
                  }
              appendHeader "Set-Cookie" cookieStr msg
              appendHeader "Set-Cookie" traceCookieStr msg
              appendHeader "Set-Cookie" csrfCookieStr msg
              appendHeader "Set-Cookie" refreshCookieStr msg
              appendHeader "Set-Cookie" refreshTraceCookieStr msg

              let responseString = unsafeStringify $ writeImpl { success: true, token: pasetoToken, user: { id: userId, email, adFree, hasPaidLastYear } }
              _ <- writeString (toWriteable msg) UTF8 responseString
              end (toWriteable msg)

handleAuthRefresh :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleAuthRefresh ctx req res = do
  let mCookieHeader = Object.lookup "cookie" (IncomingMessage.headers req)
  let
    parsedCookies = case mCookieHeader of
      Just ch -> Cookie.parse ch
      Nothing -> Object.empty
  let mRefreshToken = Object.lookup "refresh_token" parsedCookies

  case mRefreshToken of
    Nothing -> respondUnknown req res "No refresh token provided"
    Just refreshToken -> do
      runId <- ʌ Id.generate
      let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }
      let cacheKey = Cache.cacheKey "refresh_token" refreshToken "" (Nothing :: Maybe Foreign.Foreign)

      mCacheResult <- try $ runApiM ctx cause $ (Cache.get cacheKey :: _ (Maybe { userId :: UserId, email :: Email }))

      case mCacheResult of
        Right (Right (Just { userId, email })) -> do
          -- Revoke old refresh token
          _ <- try $ runApiM ctx cause $ Cache.set cacheKey 0 ""

          -- Generate new tokens
          let pasetoKey = internalConfig.auth.pasetoLocalKey
          csrfUuid <- ʌ genUUID
          let csrfToken = UUID.toString csrfUuid
          pasetoToken <- encryptV3Local pasetoKey (writeImpl { userId: userId, csrfToken: csrfToken }) "5m"

          refreshUuid <- ʌ genUUID
          let newRefreshToken = UUID.toString refreshUuid
          let newCacheKey = Cache.cacheKey "refresh_token" newRefreshToken "" (Nothing :: Maybe Foreign.Foreign)
          _ <- try $ runApiM ctx cause $ Cache.set newCacheKey refreshTokenTtlSec { userId, email }

          ʌ do
            setStatusCode 200 res
            let msg = toOutgoingMessage res
            setHeader "Content-Type" "application/json" msg
            let
              cookieStr = Cookie.serialize "session" pasetoToken
                { maxAge: 900
                , httpOnly: true
                , path: "/"
                , secure: true
                , sameSite: "lax"
                , domain: publicConfig.ui.host
                }
            let
              traceCookieStr = Cookie.serialize "session_trace" "1"
                { maxAge: 900
                , httpOnly: false
                , path: "/"
                , secure: true
                , sameSite: "lax"
                , domain: publicConfig.ui.host
                }
            let
              csrfCookieStr = Cookie.serialize "csrf_token" csrfToken
                { maxAge: 900
                , httpOnly: false
                , path: "/"
                , secure: true
                , sameSite: "lax"
                , domain: publicConfig.ui.host
                }
            let
              refreshCookieStr = Cookie.serialize "refresh_token" newRefreshToken
                { maxAge: refreshTokenTtlSec
                , httpOnly: true
                , path: "/api/auth/refresh"
                , secure: true
                , sameSite: "lax"
                , domain: publicConfig.ui.host
                }
            let
              refreshTraceCookieStr = Cookie.serialize "refresh_token_trace" "1"
                { maxAge: refreshTokenTtlSec
                , httpOnly: false
                , path: "/"
                , secure: true
                , sameSite: "lax"
                , domain: publicConfig.ui.host
                }
            appendHeader "Set-Cookie" cookieStr msg
            appendHeader "Set-Cookie" traceCookieStr msg
            appendHeader "Set-Cookie" csrfCookieStr msg
            appendHeader "Set-Cookie" refreshCookieStr msg
            appendHeader "Set-Cookie" refreshTraceCookieStr msg

            let responseString = unsafeStringify $ writeImpl { success: true, token: pasetoToken, user: { id: userId, email } }
            _ <- writeString (toWriteable msg) UTF8 responseString
            end (toWriteable msg)

        _ -> respondUnknown req res "Invalid or expired refresh token"

sendJsonResponse :: ServerResponse -> Int -> ∀ a. WriteForeign a => a -> Aff Ɩ
sendJsonResponse res statusCode a = ʌ do
  setStatusCode statusCode res
  let msg = toOutgoingMessage res
  setHeader "Content-Type" "application/json" msg
  let responseString = unsafeStringify $ writeImpl a
  _ <- writeString (toWriteable msg) UTF8 responseString
  end (toWriteable msg)

clearCookies :: OutgoingMessage -> Effect Unit
clearCookies msg = do
  let cookieStr = Cookie.serialize "session" "" { maxAge: 0, httpOnly: true, path: "/", secure: true, sameSite: "lax", domain: publicConfig.ui.host }
  let traceCookieStr = Cookie.serialize "session_trace" "" { maxAge: 0, httpOnly: false, path: "/", secure: true, sameSite: "lax", domain: publicConfig.ui.host }
  let csrfCookieStr = Cookie.serialize "csrf_token" "" { maxAge: 0, httpOnly: false, path: "/", secure: true, sameSite: "lax", domain: publicConfig.ui.host }
  let refreshCookieStr = Cookie.serialize "refresh_token" "" { maxAge: 0, httpOnly: true, path: "/api/auth/refresh", secure: true, sameSite: "lax", domain: publicConfig.ui.host }
  let refreshTraceCookieStr = Cookie.serialize "refresh_token_trace" "" { maxAge: 0, httpOnly: false, path: "/", secure: true, sameSite: "lax", domain: publicConfig.ui.host }
  appendHeader "Set-Cookie" cookieStr msg
  appendHeader "Set-Cookie" traceCookieStr msg
  appendHeader "Set-Cookie" csrfCookieStr msg
  appendHeader "Set-Cookie" refreshCookieStr msg
  appendHeader "Set-Cookie" refreshTraceCookieStr msg

handleAuthLogout :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleAuthLogout ctx req res = do
  runId <- ʌ Id.generate
  let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }
  cookieHeader <- η $ Object.lookup "cookie" (IncomingMessage.headers req)
  let parsedCookies = Cookie.parse (cookieHeader ??⇒ "")
  case Object.lookup "refresh_token" parsedCookies of
    Just refreshToken -> do
      let oldCacheKey = Cache.cacheKey "refresh_token" refreshToken "" (Nothing :: Maybe Foreign.Foreign)
      _ <- try $ runApiM ctx cause $ Cache.set oldCacheKey 0 ""
      ηι
    Nothing -> ηι

  ʌ do
    setStatusCode 200 res
    let msg = toOutgoingMessage res
    setHeader "Content-Type" "application/json" msg
    clearCookies msg
    let responseString = unsafeStringify $ writeImpl { success: true }
    _ <- writeString (toWriteable msg) UTF8 responseString
    end (toWriteable msg)
