module Core.Mod.Book.Year.Message.Field.MaybeYear where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Book.Year.Year as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)
import Core.Mod.Book.Year.Message.Field.InnerYear (InnerYearField)
import Core.Mod.Book.Year.Message.Field.Approximately (ApproximatelyField)

type Year = Maybe Base.Year

newtype YearField = YearField Year

type YearFieldChildren =
  ( year :: InnerYearField
  , approximately :: ApproximatelyField
  )

description :: String
description = "Book year"

instance IsField YearField Year YearFieldChildren where
  name = "Year"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype YearField _
derive newtype instance ReadForeign YearField
derive newtype instance WriteForeign YearField
derive newtype instance Eq YearField
derive newtype instance Show YearField
