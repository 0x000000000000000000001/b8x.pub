module Core.Mod.NewsTopic.Id.Message.Field.MaybeNewsTopic where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.NewsTopic.Id.Message.Field.Util as Util
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type NewsTopic = Maybe NewsTopicId

newtype NewsTopicField = NewsTopicField NewsTopic

instance IsField NewsTopicField NewsTopic () where
  name = "NewsTopic"

  description = Util.description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

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
