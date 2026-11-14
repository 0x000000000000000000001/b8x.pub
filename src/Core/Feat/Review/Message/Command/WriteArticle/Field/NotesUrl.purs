module Core.Feat.Review.Message.Command.WriteArticle.Field.NotesUrl where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Url.Url as Base
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Yoga.JSON (class ReadForeign, class WriteForeign)

type NotesUrl = Maybe Base.Url

newtype NotesUrlField = NotesUrlField NotesUrl

description :: String
description = "Notes URL (.docx file)"

instance IsField NotesUrlField NotesUrl () where
  name = "Notes"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NotesUrlField _
derive newtype instance ReadForeign NotesUrlField
derive newtype instance WriteForeign NotesUrlField
derive newtype instance Eq NotesUrlField
derive newtype instance Show NotesUrlField
