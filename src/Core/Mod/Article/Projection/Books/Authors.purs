module Core.Mod.Article.Projection.Books.Authors where

import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author

type Author =
  { id :: AuthorId
  , name :: Author.Name
  }

type Authors = Array Author
