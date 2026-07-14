module Core.Mod.Editor.Id.Message.Field.MaybeEditor where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Editor.Id.Message.Field.Util as Util
import Core.Mod.Editor.Id.Id (EditorId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Editor = Maybe EditorId

newtype EditorField = EditorField Editor

instance IsField EditorField Editor () where
  name = "Editor"

  description = Util.description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype EditorField _
derive newtype instance ReadForeign EditorField
derive newtype instance WriteForeign EditorField
derive newtype instance Eq EditorField
derive newtype instance Show EditorField
