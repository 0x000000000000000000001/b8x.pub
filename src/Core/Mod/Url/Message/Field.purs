module Core.Mod.Url.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Url.Url as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Url = Base.Url

newtype UrlField = UrlField Url

description :: String
description = "URL"

instance IsField UrlField Url () where
  name = "URL"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype UrlField _
derive newtype instance ReadForeign UrlField
derive newtype instance WriteForeign UrlField
derive newtype instance Eq UrlField
derive newtype instance Show UrlField
