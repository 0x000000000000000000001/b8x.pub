module Core.Mod.Author.Id.Message.Field.After where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Author.Id.Id (AuthorId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type AfterAuthor = Maybe AuthorId

newtype AfterAuthorField = AfterAuthorField AfterAuthor

description :: String
description = "After author ID"

instance IsField AfterAuthorField AfterAuthor () where
  name = "Author"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype AfterAuthorField _
derive newtype instance ReadForeign AfterAuthorField
derive newtype instance WriteForeign AfterAuthorField
derive newtype instance Eq AfterAuthorField
derive newtype instance Show AfterAuthorField
