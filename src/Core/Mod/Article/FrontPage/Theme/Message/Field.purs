module Core.Mod.Article.FrontPage.Theme.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Article.FrontPage.Theme.Theme as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Theme = Base.Theme

newtype ThemeField = ThemeField Theme

description :: String
description = "Front page theme"

instance IsField ThemeField Theme () where
  name = "Theme"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ThemeField _
derive newtype instance ReadForeign ThemeField
derive newtype instance WriteForeign ThemeField
derive newtype instance Eq ThemeField
derive newtype instance Show ThemeField
