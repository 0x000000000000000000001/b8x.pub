module Core.Mod.Article.Notes.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Mod.Html.Message.Field (defaultHtmlSanitize)
import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultShouldSanitizeInner)
import Core.Mod.Article.Notes.Notes as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Notes = Base.Notes

newtype NotesField = NotesField Notes

description :: String
description = "Article notes"

instance IsField NotesField Notes () where
  name = "Notes"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultHtmlSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NotesField _
derive newtype instance ReadForeign NotesField
derive newtype instance WriteForeign NotesField
derive newtype instance Eq NotesField
derive newtype instance Show NotesField
