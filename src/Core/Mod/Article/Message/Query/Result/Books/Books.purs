module Core.Mod.Book.Message.Query.Result.Books where

import Proem

import Core.Message.Query.Result (Fold, Return)
import Core.Mod.Image.Message.Query.Result (Image)
import Core.Mod.Book.Message.Query.Result.Authors (Author)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Name.Name as BookName
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Editor.Name.Name as EditorName
import Data.Maybe (Maybe)
import Data.Lens (Lens')
import Data.Lens.Record (prop)

type Books = Fold (Array BookId) (Array Book_)

type Book_ =
  { id :: Return BookId
  , name :: Return BookName.Name
  , year :: Return (Maybe Year)
  , cover :: Return (Maybe Image)
  , authors :: Return (Array Author)
  , editor :: Return (Maybe EditorName.Name)
  }

_name :: Lens' Book_ (Return BookName.Name)
_name = prop (π @"name")

_authors :: Lens' Book_ (Return (Array Author))
_authors = prop (π @"authors")

_editor :: Lens' Book_ (Return (Maybe EditorName.Name))
_editor = prop (π @"editor")
