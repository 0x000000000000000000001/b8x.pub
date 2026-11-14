module Core.Mod.Book.Year.Message.Field.InnerYear where

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Time.Year (Year)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Yoga.JSON (class ReadForeign, class WriteForeign)

newtype InnerYearField = InnerYearField Year

derive instance Newtype InnerYearField _
derive newtype instance ReadForeign InnerYearField
derive newtype instance WriteForeign InnerYearField
derive newtype instance Eq InnerYearField
derive newtype instance Show InnerYearField

description :: String
description = "Book year"

instance IsField InnerYearField Year () where
  name = "Year"
  description = description
  presence = Required
  sanitize = κ Intact
  shouldSanitizeInner = defaultShouldSanitizeInner
  cli = { description, multiline: false, choices: Nothing }
