module Core.Mod.MagazineIssue.Complement.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Complement.Complement as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Complement = Base.Complement

newtype ComplementField = ComplementField Complement

description :: String
description = "Whether the magazine issue is a complement"

instance IsField ComplementField Complement () where
  name = "Complement"

  description = description

  presence = Required

  sanitize = defaultSanitize (Corrected false)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ComplementField _
derive newtype instance ReadForeign ComplementField
derive newtype instance WriteForeign ComplementField
derive newtype instance Eq ComplementField
derive newtype instance Show ComplementField
