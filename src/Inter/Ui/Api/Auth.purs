module Inter.Ui.Api.Auth where

import Util.Foreign.Native as Util.Foreign.Native
import Proem
import Control.Monad.Except as Control.Monad.Except

import Affjax as Affjax
import Affjax.RequestHeader as Affjax.RequestHeader
import Affjax.RequestBody as RequestBody
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Config.PublicConfig (publicConfig)
import Yoga.JSON (class ReadForeign, readImpl, writeImpl, unsafeStringify)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Inter.Ui.Remote (getCsrfToken)
import Inter.Ui.UiM (UiM)
import Web.HTML (window)
import Web.HTML.Window (location)
import Web.HTML.Location (pathname, search)
import Util.Http.Http as Http
import Control.Monad.Except (runExcept)
import Core.Mod.Email.Email (Email)

data VerifyResult
  = VerifySuccess { email :: Email, adFree :: Boolean, hasPaidLastYear :: Boolean }
  | VerifyExpired
  | VerifyAlreadyLoggedIn

instance ReadForeign VerifyResult where
  readImpl json = do
    (obj :: { error :: String }) <- readImpl json
    if obj.error == "ALREADY_LOGGED_IN_SAME_USER" then pure VerifyAlreadyLoggedIn
    else pure VerifyExpired

liftToUi :: ∀ a. Aff a -> UiM a
liftToUi = liftAff

requestMagicLink :: String -> UiM Boolean
requestMagicLink email = do
  csrfToken <- liftToUi $ liftEffect getCsrfToken
  w <- liftToUi $ liftEffect window
  l <- liftToUi $ liftEffect $ location w
  p <- liftToUi $ liftEffect $ pathname l
  s <- liftToUi $ liftEffect $ search l
  let returnTo = p <> s
  let url = "/api/auth/magic-link/send"
  let payload = writeImpl { email, returnTo }
  let
    request = Affjax.defaultRequest
      { url = url
      , method = Left POST
      , content = Just $ RequestBody.string (unsafeStringify payload)
      , headers = [ Affjax.RequestHeader.RequestHeader "Content-Type" "application/json", Affjax.RequestHeader.RequestHeader "X-App-Id" publicConfig.ui.appId ] <> (if csrfToken /= "" then [ Affjax.RequestHeader.RequestHeader "X-Csrf-Token" csrfToken ] else [])
      , responseFormat = ResponseFormat.ignore
      , withCredentials = true
      }
  res <- liftToUi $ Http.request request
  case res of
    Right response -> do
      let (StatusCode code) = response.status
      η (code >= 200 && code < 300)
    Left _ -> do
      liftEffect $ Console.error "Error requesting magic link"
      η false

verifyMagicLink :: String -> UiM VerifyResult
verifyMagicLink tokenStr = do
  csrfToken <- liftToUi $ liftEffect getCsrfToken
  let url = "/api/auth/magic-link/consume"
  let payload = writeImpl { token: tokenStr }
  let
    request = Affjax.defaultRequest
      { url = url
      , method = Left POST
      , content = Just $ RequestBody.string (unsafeStringify payload)
      , headers = [ Affjax.RequestHeader.RequestHeader "Content-Type" "application/json", Affjax.RequestHeader.RequestHeader "X-App-Id" publicConfig.ui.appId ] <> (if csrfToken /= "" then [ Affjax.RequestHeader.RequestHeader "X-Csrf-Token" csrfToken ] else [])
      , responseFormat = ResponseFormat.string
      , withCredentials = true
      }
  res <- liftToUi $ Http.request request
  case res of
    Right response -> do
      let (StatusCode code) = response.status
      if code >= 200 && code < 300 then
        case Util.Foreign.Native.parseJSON response.body of
          Right json -> case runExcept (readImpl json) of
            Right (obj :: { user :: { email :: Email, adFree :: Boolean, hasPaidLastYear :: Boolean } }) -> η (VerifySuccess { email: obj.user.email, adFree: obj.user.adFree, hasPaidLastYear: obj.user.hasPaidLastYear })
            Left _ -> η VerifyExpired
          Left _ -> η VerifyExpired
      else case Util.Foreign.Native.parseJSON response.body of
        Right json -> case Control.Monad.Except.runExcept (readImpl json) of
          Right VerifyAlreadyLoggedIn -> η VerifyAlreadyLoggedIn
          _ -> η VerifyExpired
        Left _ -> η VerifyExpired
    Left _ -> do
      liftEffect $ Console.error "Error verifying magic link"
      η VerifyExpired

apiRegisterUser :: String -> UiM Boolean
apiRegisterUser email = do
  csrfToken <- liftToUi $ liftEffect getCsrfToken
  let url = "/api/write/register-user"
  let payload = writeImpl { email }
  let
    request = Affjax.defaultRequest
      { url = url
      , method = Left POST
      , content = Just $ RequestBody.string (unsafeStringify payload)
      , headers = [ Affjax.RequestHeader.RequestHeader "Content-Type" "application/json", Affjax.RequestHeader.RequestHeader "X-App-Id" publicConfig.ui.appId ] <> (if csrfToken /= "" then [ Affjax.RequestHeader.RequestHeader "X-Csrf-Token" csrfToken ] else [])
      , responseFormat = ResponseFormat.ignore
      , withCredentials = true
      }
  res <- liftToUi $ Http.request request
  case res of
    Right response -> do
      let (StatusCode code) = response.status
      η (code >= 200 && code < 300)
    Left _ -> do
      liftEffect $ Console.error "Error registering user"
      η false
