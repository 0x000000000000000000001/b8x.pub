module Core.Mod.Author.Id.Message.Field.Author where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Author.Id.Id (AuthorId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Author = AuthorId

newtype AuthorField = AuthorField Author

instance IsField AuthorField Author () where
  name = "Author"

  description = "Author"

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: "Author"
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype AuthorField _
derive newtype instance ReadForeign AuthorField
derive newtype instance WriteForeign AuthorField
derive newtype instance Eq AuthorField
derive newtype instance Show AuthorField
