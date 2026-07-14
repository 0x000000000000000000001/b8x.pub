module Core.Mod.MagazineIssue.Special.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Special.Special as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Special = Base.Special

newtype SpecialField = SpecialField Special

description :: String
description = "Whether the magazine issue is special"

instance IsField SpecialField Special () where
  name = "Special"

  description = description

  presence = Required

  sanitize = defaultSanitize (Corrected false)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype SpecialField _
derive newtype instance ReadForeign SpecialField
derive newtype instance WriteForeign SpecialField
derive newtype instance Eq SpecialField
derive newtype instance Show SpecialField
