module Core.Mod.Author.Id.Message.Field.MaybeAuthor where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Author.Id.Id (AuthorId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Author = Maybe AuthorId

newtype AuthorField = AuthorField Author

instance IsField AuthorField Author () where
  name = "Author"

  description = "Author"

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

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
