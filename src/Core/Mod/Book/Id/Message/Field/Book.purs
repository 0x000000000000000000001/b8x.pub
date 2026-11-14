module Core.Mod.Book.Id.Message.Field.Book where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Book.Id.Id (BookId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Book = BookId

newtype BookField = BookField Book

instance IsField BookField Book () where
  name = "Book"

  description = "Book"

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: "Book"
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype BookField _
derive newtype instance ReadForeign BookField
derive newtype instance WriteForeign BookField
derive newtype instance Eq BookField
derive newtype instance Show BookField
