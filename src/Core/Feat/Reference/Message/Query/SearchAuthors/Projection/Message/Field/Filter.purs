module Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Message.Field.Filter where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Filter = Maybe Base.AuthorFilter

newtype FilterField = FilterField Filter

description :: String
description = "Author filter"

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
