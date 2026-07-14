module Core.Mod.Author.Id.Message.Field.Authors where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Author.Id.Id (AuthorId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Authors = Array AuthorId

newtype AuthorsField = AuthorsField Authors

description :: String
description = "Author IDs"

instance IsField AuthorsField Authors () where
  name = "Authors"

  description = description

  presence = Required

  sanitize = defaultSanitize (Corrected [])

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype AuthorsField _
derive newtype instance ReadForeign AuthorsField
derive newtype instance WriteForeign AuthorsField
derive newtype instance Eq AuthorsField
derive newtype instance Show AuthorsField

