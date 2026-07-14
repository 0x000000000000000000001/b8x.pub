module Inter.Ui.Router.HandleQuery where

import Proem hiding (div)

import Data.Maybe (Maybe(..))
import Halogen (modify_, tell, gets)
import Halogen as H
import Inter.Api.Social.Meta.Route.PlaceholderIndex (placeholderMeta)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Capability.Navigate.Trans (updateMeta, navigate)
import Inter.Ui.Router.Menu.Type.Query as MenuQuery
import Inter.Ui.Router.Type (RouteM, Query(..))
import Util.Html.Dom.Dom (scrollTo, setMetaRobotsNoIndex)
import Inter.Ui.Api.Auth (verifyMagicLink, VerifyResult(..))
import Inter.Ui.Capability.Toast.Trans (toast)
import Inter.Ui.Type.Toast (ToastType(..))
import Inter.Ui.Capability.Store.Trans (updateStore)
import Inter.Ui.Store.Store as GlobalStore

handleQuery :: ∀ a. Query a -> RouteM (Maybe a)
handleQuery = case _ of
  Navigate route' a -> do
    route <- gets _.route

    case route of
      Just r | equivalent r route' -> ηι
      _ -> do
        scrollTo 0 0
        updateMeta $ Just $ placeholderMeta route'

    modify_ _
      { route = Just route'
      , isUrlLoaded = true
      }

    let
      checkParams r params = do
        let searchParams = params.menu.search
        case searchParams.openWith, searchParams.withAuthorFilter of
          Nothing, Nothing -> ηι
          _, _ -> tell (π @"menu") unit (MenuQuery.OpenSearch searchParams.openWith searchParams.withAuthorFilter)

        case params.menu.magazineIssueOpen of
          Just slug -> tell (π @"menu") unit (MenuQuery.OpenMagazineIssue (Just slug))
          Nothing -> ηι

        case params.consumeMagicLoginToken of
          Just token -> do
            toast { id: "auth-magic-link", message: "Connexion en cours...", tType: Info }
            let updatedParams = params { consumeMagicLoginToken = Nothing }
            let
              updatedRoute = case r of
                Home _ -> Home updatedParams
                Article s _ -> Article s updatedParams
                Theme t _ -> Theme t updatedParams
                Donate _ -> Donate updatedParams
                _ -> r
            navigate updatedRoute
            _ <- H.fork $ do
              result <- H.lift $ verifyMagicLink token
              case result of
                VerifySuccess { email, adFree, hasPaidLastYear } -> do
                  updateStore (GlobalStore.Login email { adFree, hasPaidLastYear })
                  toast { id: "auth-magic-link", message: "Vous êtes maintenant connecté(e)", tType: Success }
                VerifyAlreadyLoggedIn -> toast { id: "auth-magic-link", message: "Vous êtes déjà connecté(e)", tType: Info }
                VerifyExpired -> toast { id: "auth-magic-link", message: "Lien expiré ou invalide, veuillez en demander un nouveau", tType: Error }
            ηι
          Nothing -> ηι

    case route' of
      NotFound -> ʌ setMetaRobotsNoIndex
      Home params -> checkParams route' params
      Article _ params -> checkParams route' params
      Theme _ params -> checkParams route' params
      Donate params -> checkParams route' params

    η (Just a)

-- | Not equal but equivalent. 
-- | E.g. article with the same slug but differents params.
equivalent :: Route -> Route -> Boolean
equivalent (Home _) = case _ of
  Home _ -> true
  _ -> false
equivalent (Article s1 _) = case _ of
  Article s2 _ -> s1 == s2
  _ -> false
equivalent (Theme t1 _) = case _ of
  Theme t2 _ -> t1 == t2
  _ -> false
equivalent (Donate _) = case _ of
  Donate _ -> true
  _ -> false
equivalent NotFound = case _ of
  NotFound -> true
  _ -> false
