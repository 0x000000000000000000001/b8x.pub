module Inter.Ui.Router.HandleAction.HandleMenuOutput.Opened (handleMenuOutputOpened) where

import Proem

import Data.Maybe (Maybe(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuOpened (navigateToCurrentRouteWithMenuOpened)
import Inter.Ui.Router.Menu.Type.Output (WithSearchOpen(..))
import Inter.Ui.Router.Type (RouteM)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)


handleMenuOutputOpened :: { search :: WithSearchOpen, authorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }, magazineIssueOpen :: Maybe Slug } -> RouteM Ɩ
handleMenuOutputOpened { search: withSearchOpen, authorFilter, magazineIssueOpen } = do
  let
    query =
      case withSearchOpen of
        YesWithQuery q -> Just q
        No -> Nothing

    activeAuthorFilter =
      case withSearchOpen of
        YesWithQuery _ -> authorFilter
        No -> Nothing

  navigateToCurrentRouteWithMenuOpened query activeAuthorFilter magazineIssueOpen
