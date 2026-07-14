module Core.Event.BookReferenced.Payload where

import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Name.Name (Name)
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Image.Image (Image)
import Data.Maybe (Maybe)

type Payload =
  { id :: BookId
  , name :: Name
  , authors :: Array AuthorId
  , editor :: Maybe EditorId
  , year :: Maybe Year
  , cover :: Maybe Image
  , legacyId :: Maybe Int
  }
