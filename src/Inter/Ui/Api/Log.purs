module Inter.Ui.Api.Log where

import Proem

import Affjax as Affjax
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader as Affjax.RequestHeader
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Config.PublicConfig (publicConfig)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Inter.Ui.Api.CsrfToken (getCsrfToken)
import Inter.Ui.UiM (UiM)
import Util.Http.Http as Http
import Yoga.JSON (unsafeStringify, writeImpl)

liftToUi :: ∀ a. Aff a -> UiM a
liftToUi = liftAff

apiLogUiBug :: { error :: String, url :: String } -> UiM Boolean
apiLogUiBug { error, url: errorUrl } = do
  csrfToken <- liftToUi $ liftEffect getCsrfToken
  
  let endpoint = "/api/log/ui-bug"
  let payload = writeImpl { url: errorUrl, error, userAgent: (Nothing :: Maybe String) }
  
  let
    request = Affjax.defaultRequest
      { url = endpoint
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
      liftEffect $ Console.error "Error reporting UI bug"
      η false
