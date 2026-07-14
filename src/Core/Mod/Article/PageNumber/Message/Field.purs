module Core.Mod.Article.PageNumber.Message.Field where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Article.PageNumber.PageNumber as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type PageNumber = Base.PageNumber

newtype PageNumberField = PageNumberField PageNumber

description :: String
description = "Page number"

instance IsField PageNumberField PageNumber () where
  name = "PageNumber"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype PageNumberField _
derive newtype instance ReadForeign PageNumberField
derive newtype instance WriteForeign PageNumberField
derive newtype instance Eq PageNumberField
derive newtype instance Show PageNumberField
