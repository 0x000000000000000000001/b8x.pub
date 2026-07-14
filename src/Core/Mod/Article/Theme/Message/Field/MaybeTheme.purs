module Core.Mod.Article.Theme.Message.Field.MaybeTheme where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Message.Field.Field as IsField
import Core.Mod.Article.Theme.Message.Field.Theme as BaseField
import Core.Mod.Article.Theme.Theme as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

type Theme = Maybe Base.Theme

newtype ThemeField = ThemeField Theme

description :: String
description = IsField.description @BaseField.ThemeField

instance IsField ThemeField Theme () where
  name = "Theme"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli = IsField.cli @BaseField.ThemeField

derive instance Newtype ThemeField _
derive newtype instance ReadForeign ThemeField
derive newtype instance WriteForeign ThemeField
derive newtype instance Eq ThemeField
derive newtype instance Show ThemeField
