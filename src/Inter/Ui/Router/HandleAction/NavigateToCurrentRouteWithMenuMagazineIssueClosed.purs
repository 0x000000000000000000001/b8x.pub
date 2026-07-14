module Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuMagazineIssueClosed (navigateToCurrentRouteWithMenuMagazineIssueClosed) where

import Proem

import Data.Maybe (Maybe(..))
import Halogen (gets)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Capability.Navigate.Trans (navigate)
import Inter.Ui.Router.Type (RouteM)

navigateToCurrentRouteWithMenuMagazineIssueClosed :: RouteM Ɩ
navigateToCurrentRouteWithMenuMagazineIssueClosed = do
  route <- gets _.route
  case route of
    Just (Home r) -> navigate (Home r { menu { magazineIssueOpen = Nothing } })
    Just (Theme th r) -> navigate (Theme th r { menu { magazineIssueOpen = Nothing } })
    Just (Article slug r) -> navigate (Article slug r { menu { magazineIssueOpen = Nothing } })
    _ -> ηι
