module Inter.Ui.Router.HandleAction.HandleMenuOutput.SearchClosed (handleMenuOutputSearchClosed) where

import Proem


import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuSearchClosed (navigateToCurrentRouteWithMenuSearchClosed)
import Inter.Ui.Router.Type (RouteM)

handleMenuOutputSearchClosed :: RouteM Ɩ
handleMenuOutputSearchClosed = do
  navigateToCurrentRouteWithMenuSearchClosed
