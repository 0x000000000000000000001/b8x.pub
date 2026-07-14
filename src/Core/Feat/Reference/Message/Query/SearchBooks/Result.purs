module Core.Feat.Reference.Message.Query.SearchBooks.Result where

import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Name.Name (Name)
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Image.Message.Query.Result as Result
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Message.Query.Result (Return)
import Data.Maybe (Maybe)

type Result =
  { books ::
      Array
        { id :: Return BookId
        , name :: Return Name
        , year :: Return (Maybe Year)
        , cover :: Return (Maybe Result.Image)
        , authors :: Return (Array AuthorId)
        , editor :: Return (Maybe EditorId)
        }
  , limit :: Int
  , hasNextPage :: Boolean
  }
