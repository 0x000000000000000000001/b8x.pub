module Core.Mod.Editor.Id.Message.Field.AfterEditor where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Editor.Id.Id (EditorId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type AfterEditor = Maybe EditorId

newtype AfterEditorField = AfterEditorField AfterEditor

description :: String
description = "Pagination cursor pointing to the last parsed editor"

instance IsField AfterEditorField AfterEditor () where
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

derive instance Newtype AfterEditorField _
derive newtype instance ReadForeign AfterEditorField
derive newtype instance WriteForeign AfterEditorField
derive newtype instance Eq AfterEditorField
derive newtype instance Show AfterEditorField
