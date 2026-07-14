module Core.Mod.Email.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Email.Email as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Email = Base.Email

newtype EmailField = EmailField Email

description :: String
description = "Email"

instance IsField EmailField Email () where
  name = "Email"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype EmailField _
derive newtype instance ReadForeign EmailField
derive newtype instance WriteForeign EmailField
derive newtype instance Eq EmailField
derive newtype instance Show EmailField
