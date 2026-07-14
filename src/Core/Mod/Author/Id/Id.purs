module Core.Mod.Author.Id.Id
  (AuthorId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.Author.Author (Author)

type AuthorId = Id.Id Author
