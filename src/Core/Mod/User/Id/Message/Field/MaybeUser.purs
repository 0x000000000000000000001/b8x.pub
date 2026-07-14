module Core.Mod.User.Id.Message.Field.MaybeUser where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.User.Id.Message.Field.Util as Util
import Core.Mod.User.Id.Id (UserId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type User = Maybe UserId

newtype UserField = UserField User

instance IsField UserField User () where
  name = "User"

  description = Util.description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

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
