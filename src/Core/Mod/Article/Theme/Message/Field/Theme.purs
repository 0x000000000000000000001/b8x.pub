module Core.Mod.Article.Theme.Message.Field.Theme where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner, enumChoices)
import Core.Mod.Article.Theme.Theme as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Theme = Base.Theme

newtype ThemeField = ThemeField Theme

description :: String
description = "Article theme"

instance IsField ThemeField Theme () where
  name = "Theme"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Just $ enumChoices @Theme
    }

derive instance Newtype ThemeField _
derive newtype instance ReadForeign ThemeField
derive newtype instance WriteForeign ThemeField
derive newtype instance Eq ThemeField
derive newtype instance Show ThemeField
