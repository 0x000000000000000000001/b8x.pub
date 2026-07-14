module Core.Mod.Article.Identifier.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Article.Identifier.ArticleIdentifier as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type ArticleIdentifier = Base.ArticleIdentifier

newtype ArticleIdentifierField = ArticleIdentifierField ArticleIdentifier

description :: String
description = "An article identifier (ID or slug)"

instance IsField ArticleIdentifierField ArticleIdentifier () where
  name = "ArticleIdentifier"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ArticleIdentifierField _
derive newtype instance ReadForeign ArticleIdentifierField
derive newtype instance WriteForeign ArticleIdentifierField
derive newtype instance Eq ArticleIdentifierField
derive newtype instance Show ArticleIdentifierField
