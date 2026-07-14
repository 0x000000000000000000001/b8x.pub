module Core.Mod.Book.Id.Message.Field.MaybeBook where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Book.Id.Message.Field.Util as Util
import Core.Mod.Book.Id.Id (BookId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Book = Maybe BookId

newtype BookField = BookField Book

instance IsField BookField Book () where
  name = "Book"

  description = Util.description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype BookField _
derive newtype instance ReadForeign BookField
derive newtype instance WriteForeign BookField
derive newtype instance Eq BookField
derive newtype instance Show BookField
