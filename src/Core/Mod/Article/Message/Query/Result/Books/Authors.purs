module Core.Mod.Book.Message.Query.Result.Authors where

import Proem

import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as AuthorName
import Data.Lens (Lens')
import Data.Lens.Record (prop)

type Author =
  { id :: AuthorId
  , name :: AuthorName.Name
  }

_id :: Lens' Author AuthorId
_id = prop (π @"id")

_name :: Lens' Author AuthorName.Name
_name = prop (π @"name")
