module Core.Mod.NewsTopic.Id.Message.Field.Id where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.NewsTopic.Id.Message.Field.Util as Util
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Id = NewsTopicId

newtype IdField = IdField Id

instance IsField IdField Id () where
  name = "Id"

  description = Util.description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype IdField _
derive newtype instance ReadForeign IdField
derive newtype instance WriteForeign IdField
derive newtype instance Eq IdField
derive newtype instance Show IdField
