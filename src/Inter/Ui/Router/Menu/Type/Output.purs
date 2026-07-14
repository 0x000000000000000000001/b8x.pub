module Inter.Ui.Router.Menu.Type.Output where

import Data.Maybe (Maybe)

import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author

data WithSearchOpen = YesWithQuery String | No

data Output
  = OpenSearchQueryChanged { query :: String, authorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean } }
  | SearchOpened { query :: String, authorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean } }
  | SearchClosed
  | Opened { search :: WithSearchOpen, authorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }, magazineIssueOpen :: Maybe Slug }
  | Closed
  | AuthorFilterRemoved
  | MagazineIssueOpened Slug
  | MagazineIssueClosed
