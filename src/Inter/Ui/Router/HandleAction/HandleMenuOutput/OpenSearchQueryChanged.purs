module Inter.Ui.Router.HandleAction.HandleMenuOutput.OpenSearchQueryChanged (handleMenuOutputOpenSearchQueryChanged) where

import Proem

import Inter.Ui.Router.Type (RouteM)
import Data.Maybe (Maybe(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuSearchOpen (navigateToCurrentRouteWithMenuSearchOpen)

handleMenuOutputOpenSearchQueryChanged :: { query :: String, authorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean } } -> RouteM Ɩ
handleMenuOutputOpenSearchQueryChanged { query, authorFilter } =
  navigateToCurrentRouteWithMenuSearchOpen (Just query) authorFilter
