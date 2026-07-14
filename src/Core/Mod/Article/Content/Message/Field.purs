module Core.Mod.Article.Content.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Article.Content.Content as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Content = Base.Content

newtype ContentField = ContentField Content

description :: String
description = "Article content"

instance IsField ContentField Content () where
  name = "Content"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: true
    , choices: Nothing
    }

derive instance Newtype ContentField _
derive newtype instance ReadForeign ContentField
derive newtype instance WriteForeign ContentField
derive newtype instance Eq ContentField
derive newtype instance Show ContentField
