module Inter.Ui.Router.HandleAction.HandleMenuOutput.Index (handleMenuOutput) where

import Proem

import Inter.Ui.Router.Menu.Type.Output as MenuOutput
import Inter.Ui.Router.Type (RouteM)
import Inter.Ui.Router.HandleAction.HandleMenuOutput.OpenSearchQueryChanged (handleMenuOutputOpenSearchQueryChanged)
import Inter.Ui.Router.HandleAction.HandleMenuOutput.SearchOpened (handleMenuOutputSearchOpened)
import Inter.Ui.Router.HandleAction.HandleMenuOutput.SearchClosed (handleMenuOutputSearchClosed)
import Inter.Ui.Router.HandleAction.HandleMenuOutput.Closed (handleMenuOutputClosed)
import Inter.Ui.Router.HandleAction.HandleMenuOutput.Opened (handleMenuOutputOpened)
import Inter.Ui.Router.HandleAction.HandleMenuOutput.AuthorFilterRemoved (handleMenuOutputAuthorFilterRemoved)
import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuMagazineIssueOpen (navigateToCurrentRouteWithMenuMagazineIssueOpen)
import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuMagazineIssueClosed (navigateToCurrentRouteWithMenuMagazineIssueClosed)

handleMenuOutput :: MenuOutput.Output -> RouteM Ɩ
handleMenuOutput = case _ of
  MenuOutput.OpenSearchQueryChanged query -> handleMenuOutputOpenSearchQueryChanged query
  MenuOutput.SearchOpened query -> handleMenuOutputSearchOpened query
  MenuOutput.SearchClosed -> handleMenuOutputSearchClosed
  MenuOutput.Closed -> handleMenuOutputClosed
  MenuOutput.Opened payload -> handleMenuOutputOpened payload
  MenuOutput.AuthorFilterRemoved -> handleMenuOutputAuthorFilterRemoved
  MenuOutput.MagazineIssueOpened slug -> navigateToCurrentRouteWithMenuMagazineIssueOpen slug
  MenuOutput.MagazineIssueClosed -> navigateToCurrentRouteWithMenuMagazineIssueClosed
