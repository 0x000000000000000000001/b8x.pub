module Core.Mod.Book.Id.Message.Field.Books where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Book.Id.Message.Field.Util as Util
import Core.Mod.Book.Id.Id (BookId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Books = Array BookId

newtype BooksField = BooksField Books

instance IsField BooksField Books () where
  name = "Books"

  description = Util.description

  presence = Optional (η []) "None"

  sanitize = defaultSanitize (Corrected [])

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype BooksField _
derive newtype instance ReadForeign BooksField
derive newtype instance WriteForeign BooksField
derive newtype instance Eq BooksField
derive newtype instance Show BooksField
