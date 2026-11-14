module Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Message.Field.Filter where

import Proem

import Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Projection as Base
import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Filter = Maybe Base.NewsTopicFilter

newtype NewsTopicFilterField = NewsTopicFilterField Filter

description :: String
description = "News topic filter"

instance IsField NewsTopicFilterField Filter () where
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

derive instance Newtype NewsTopicFilterField _
derive newtype instance ReadForeign NewsTopicFilterField
derive newtype instance WriteForeign NewsTopicFilterField
derive newtype instance Eq NewsTopicFilterField
derive newtype instance Show NewsTopicFilterField
