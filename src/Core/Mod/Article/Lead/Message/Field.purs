module Core.Mod.Article.Lead.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Mod.Html.Message.Field (defaultHtmlSanitize)
import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultShouldSanitizeInner)
import Core.Mod.Article.Lead.Lead as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Lead = Base.Lead

newtype LeadField = LeadField Lead

description :: String
description = "Article lead"

instance IsField LeadField Lead () where
  name = "Lead"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultHtmlSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype LeadField _
derive newtype instance ReadForeign LeadField
derive newtype instance WriteForeign LeadField
derive newtype instance Eq LeadField
derive newtype instance Show LeadField
