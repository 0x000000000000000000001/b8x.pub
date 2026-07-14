module Core.Mod.NewsTopic.Id.Message.Field.AfterNewsTopic where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type AfterNewsTopic = Maybe NewsTopicId

newtype AfterNewsTopicField = AfterNewsTopicField AfterNewsTopic

description :: String
description = "Pagination cursor pointing to the last parsed news topic"

instance IsField AfterNewsTopicField AfterNewsTopic () where
  name = "After"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize (Corrected Nothing)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype AfterNewsTopicField _
derive newtype instance ReadForeign AfterNewsTopicField
derive newtype instance WriteForeign AfterNewsTopicField
derive newtype instance Eq AfterNewsTopicField
derive newtype instance Show AfterNewsTopicField
