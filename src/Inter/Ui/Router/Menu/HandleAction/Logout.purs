module Inter.Ui.Router.Menu.HandleAction.Logout where

import Proem

import Affjax as Affjax
import Affjax.RequestHeader as Affjax.RequestHeader
import Affjax.ResponseFormat as ResponseFormat
import Config.PublicConfig (publicConfig)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))

import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)

import Inter.Ui.Capability.Store.Trans (updateStore)
import Inter.Ui.Capability.Toast.Trans (toast)
import Inter.Ui.Remote (getCsrfToken)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Store.Store as GlobalStore
import Inter.Ui.Type.Toast (ToastType(..))
import Util.Http.Http as Http

logout :: MenuM Ɩ
logout = do
  updateStore GlobalStore.Logout
  toast { id: "logout", message: "Déconnexion en cours...", tType: Info }
  
  csrfToken <- liftEffect getCsrfToken
  let url = "/api/auth/logout"
  let
    request = Affjax.defaultRequest
      { url = url
      , method = Left POST
      , headers = [ Affjax.RequestHeader.RequestHeader "X-App-Id" publicConfig.ui.appId ] <> (if csrfToken /= "" then [ Affjax.RequestHeader.RequestHeader "X-Csrf-Token" csrfToken ] else [])
      , responseFormat = ResponseFormat.ignore
      , withCredentials = true
      }
  res <- liftAff $ Http.request request
  case res of
    Right _ -> toast { id: "logout", message: "Vous êtes déconnecté(e)", tType: Success }
    Left _ -> toast { id: "logout", message: "Erreur lors de la déconnexion", tType: Error }
