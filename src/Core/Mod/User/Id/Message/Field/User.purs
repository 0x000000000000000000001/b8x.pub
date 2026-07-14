module Core.Mod.User.Id.Message.Field.User where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.User.Id.Message.Field.Util as Util
import Core.Mod.User.Id.Id (UserId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type User = UserId

newtype UserField = UserField User

instance IsField UserField User () where
  name = "User"

  description = Util.description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype UserField _
derive newtype instance ReadForeign UserField
derive newtype instance WriteForeign UserField
derive newtype instance Eq UserField
derive newtype instance Show UserField
