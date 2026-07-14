module Inter.Ui.Router.HandleAction.HandleMenuOutput.SearchOpened (handleMenuOutputSearchOpened) where

import Proem

import Data.Maybe (Maybe(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuSearchOpen (navigateToCurrentRouteWithMenuSearchOpen)
import Inter.Ui.Router.Type (RouteM)

handleMenuOutputSearchOpened :: { query :: String, authorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean } } -> RouteM Ɩ
handleMenuOutputSearchOpened { query, authorFilter } = do
  navigateToCurrentRouteWithMenuSearchOpen (Just query) authorFilter
