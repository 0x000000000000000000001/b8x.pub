module Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuMagazineIssueOpen (navigateToCurrentRouteWithMenuMagazineIssueOpen) where

import Proem

import Data.Maybe (Maybe(..))
import Core.Mod.MagazineIssue.Slug.Slug (Slug)

import Halogen (gets)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Capability.Navigate.Trans (navigate)
import Inter.Ui.Router.Type (RouteM)

navigateToCurrentRouteWithMenuMagazineIssueOpen :: Slug -> RouteM Ɩ
navigateToCurrentRouteWithMenuMagazineIssueOpen slug = do
  route <- gets _.route
  case route of
    Just (Home r) -> do
      navigate (Home r { menu { magazineIssueOpen = Just slug } })
    Just (Theme slugTheme r) -> navigate (Theme slugTheme r { menu { magazineIssueOpen = Just slug } })
    Just (Article slugArt r) -> navigate (Article slugArt r { menu { magazineIssueOpen = Just slug } })
    Just (Donate r) -> navigate (Donate r { menu { magazineIssueOpen = Just slug } })
    Just (About r) -> navigate (About r { menu { magazineIssueOpen = Just slug } })
    Just (Legal r) -> navigate (Legal r { menu { magazineIssueOpen = Just slug } })
    Just (Newsletter r) -> navigate (Newsletter r { menu { magazineIssueOpen = Just slug } })
    Just NotFound -> ηι
    Nothing -> ηι
