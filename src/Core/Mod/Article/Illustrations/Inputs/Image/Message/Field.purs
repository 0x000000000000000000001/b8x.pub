module Core.Mod.Article.Illustrations.Inputs.Image.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Url.Url (Url)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Image = Url

newtype ImageField = ImageField Image

description :: String
description = "Illustration image URL"

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
