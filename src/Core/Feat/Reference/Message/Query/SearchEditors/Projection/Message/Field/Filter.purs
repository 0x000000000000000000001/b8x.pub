module Core.Feat.Reference.Message.Query.SearchEditors.Projection.Message.Field.Filter where

import Proem

import Core.Feat.Reference.Message.Query.SearchEditors.Projection.Projection as Base
import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Filter = Maybe Base.EditorFilter

newtype EditorFilterField = EditorFilterField Filter

description :: String
description = "Editor filter"

instance IsField EditorFilterField Filter () where
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

derive instance Newtype EditorFilterField _
derive newtype instance ReadForeign EditorFilterField
derive newtype instance WriteForeign EditorFilterField
derive newtype instance Eq EditorFilterField
derive newtype instance Show EditorFilterField
