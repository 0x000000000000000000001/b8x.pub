module Core.Mod.Image.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Image.Image as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Image = Base.Image

newtype ImageField = ImageField Image

description :: String
description = "Image"

instance IsField ImageField Image () where
  name = "Image"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ImageField _
derive newtype instance ReadForeign ImageField
derive newtype instance WriteForeign ImageField
derive newtype instance Eq ImageField
derive newtype instance Show ImageField
