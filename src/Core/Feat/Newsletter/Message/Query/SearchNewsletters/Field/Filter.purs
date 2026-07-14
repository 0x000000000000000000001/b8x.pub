module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Field.Filter where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Filter = Maybe Base.NewsletterFilter

newtype FilterField = FilterField Filter

description :: String
description = "Newsletter filter"

instance IsField FilterField Filter () where
  name = "Filter"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize (Corrected Nothing)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype FilterField _
derive newtype instance ReadForeign FilterField
derive newtype instance WriteForeign FilterField
derive newtype instance Eq FilterField
derive newtype instance Show FilterField
