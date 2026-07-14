module Core.Mod.NewsTopic.Id.Message.Field.NewsTopic where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.NewsTopic.Id.Message.Field.Util as Util
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type NewsTopic = NewsTopicId

newtype NewsTopicField = NewsTopicField NewsTopic

instance IsField NewsTopicField NewsTopic () where
  name = "NewsTopic"

  description = Util.description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NewsTopicField _
derive newtype instance ReadForeign NewsTopicField
derive newtype instance WriteForeign NewsTopicField
derive newtype instance Eq NewsTopicField
derive newtype instance Show NewsTopicField
