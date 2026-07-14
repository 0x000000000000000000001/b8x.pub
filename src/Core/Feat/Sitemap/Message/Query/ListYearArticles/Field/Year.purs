module Core.Feat.Sitemap.Message.Query.ListYearArticles.Field.Year where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Time.Year as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Year = Base.Year

newtype YearField = YearField Year

description :: String
description = "Year"

instance IsField YearField Year () where
  name = "Year"

  description = description

  presence = Required

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
