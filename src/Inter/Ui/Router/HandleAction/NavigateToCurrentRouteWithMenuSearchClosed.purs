module Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuSearchClosed (navigateToCurrentRouteWithMenuSearchClosed) where

import Proem

import Data.Maybe (Maybe(..))
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Capability.Navigate.Trans (navigate)
import Inter.Ui.Router.Type (RouteM)
import Halogen (gets)

navigateToCurrentRouteWithMenuSearchClosed :: RouteM Ɩ
navigateToCurrentRouteWithMenuSearchClosed = do
  let updateSearch searchParams = searchParams { openWith = Nothing, withAuthorFilter = Nothing }

  route <- gets _.route

  case route of
    Just (Home r) -> navigate (Home r { menu { search = updateSearch r.menu.search } })
    Just (Theme slug r) -> navigate (Theme slug r { menu { search = updateSearch r.menu.search } })
    Just (Article slug r) -> navigate (Article slug r { menu { search = updateSearch r.menu.search } })
    Just (Donate r) -> navigate (Donate r { menu { search = updateSearch r.menu.search } })
    Just (About r) -> navigate (About r { menu { search = updateSearch r.menu.search } })
    Just (Legal r) -> navigate (Legal r { menu { search = updateSearch r.menu.search } })
    Just (Newsletter r) -> navigate (Newsletter r { menu { search = updateSearch r.menu.search } })
    _ -> ηι
