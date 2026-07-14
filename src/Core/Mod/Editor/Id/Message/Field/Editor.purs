module Core.Mod.Editor.Id.Message.Field.Editor where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Editor.Id.Message.Field.Util as Util
import Core.Mod.Editor.Id.Id (EditorId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Editor = EditorId

newtype EditorField = EditorField Editor

instance IsField EditorField Editor () where
  name = "Editor"

  description = Util.description

  presence = Required

  sanitize = κ Intact

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
