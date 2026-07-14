module Inter.Ui.Router.Menu.Type.Query where

import Data.Maybe (Maybe)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author

import Core.Mod.MagazineIssue.Slug.Slug as MagazineIssueSlug

data Query a
  = FocusSearchInput a
  | OpenSearch (Maybe String) (Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }) a
  | OpenMagazineIssue (Maybe MagazineIssueSlug.Slug) a
