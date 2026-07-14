module Inter.Ui.Router.HandleAction.HandleMenuOutput.Closed (handleMenuOutputClosed) where

import Proem

import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuSearchClosed (navigateToCurrentRouteWithMenuSearchClosed)
import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuMagazineIssueClosed (navigateToCurrentRouteWithMenuMagazineIssueClosed)
import Inter.Ui.Router.Type (RouteM)

handleMenuOutputClosed :: RouteM Ɩ
handleMenuOutputClosed = do
  navigateToCurrentRouteWithMenuSearchClosed
  navigateToCurrentRouteWithMenuMagazineIssueClosed
