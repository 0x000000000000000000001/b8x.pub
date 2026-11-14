module Core.Mod.Book.Year.Message.Field.Approximately where

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Yoga.JSON (class ReadForeign, class WriteForeign)

newtype ApproximatelyField = ApproximatelyField Boolean

derive instance Newtype ApproximatelyField _
derive newtype instance ReadForeign ApproximatelyField
derive newtype instance WriteForeign ApproximatelyField
derive newtype instance Eq ApproximatelyField
derive newtype instance Show ApproximatelyField

description :: String
description = "Is it approximate?"

instance IsField ApproximatelyField Boolean () where
  name = "Approximately"
  description = description
  presence = Optional (η false) "no"
  sanitize = κ Intact
  shouldSanitizeInner = defaultShouldSanitizeInner
  cli = { description, multiline: false, choices: Nothing }
