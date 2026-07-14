module Core.Mod.Time.Message.Field.Instant where

import Data.Maybe (Maybe(..))
import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Time.Instant as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Instant = Base.Instant

newtype InstantField = InstantField Instant

description :: String
description = "Instant"

instance IsField InstantField Instant () where
  name = "Instant"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner
  
  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype InstantField _
derive newtype instance ReadForeign InstantField
derive newtype instance WriteForeign InstantField
derive newtype instance Eq InstantField
derive newtype instance Show InstantField
