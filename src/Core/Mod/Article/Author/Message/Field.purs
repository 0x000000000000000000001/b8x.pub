module Core.Mod.Article.Author.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Article.Author.Author as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Author = Base.Author

newtype AuthorField = AuthorField Author

description :: String
description = "Article author ID"

instance IsField AuthorField Author () where
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

derive instance Newtype AuthorField _
derive newtype instance ReadForeign AuthorField
derive newtype instance WriteForeign AuthorField
derive newtype instance Eq AuthorField
derive newtype instance Show AuthorField
