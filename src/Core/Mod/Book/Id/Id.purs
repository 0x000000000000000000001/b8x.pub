module Core.Mod.Book.Id.Id
  (BookId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.Book.Book (Book)

type BookId = Id.Id Book
