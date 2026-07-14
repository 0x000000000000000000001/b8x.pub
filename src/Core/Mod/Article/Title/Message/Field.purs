module Core.Mod.Article.Title.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Article.Title.Title as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Title = Base.Title

newtype TitleField = TitleField Title

description :: String
description = "Article title"

instance IsField TitleField Title () where
  name = "Title"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype TitleField _
derive newtype instance ReadForeign TitleField
derive newtype instance WriteForeign TitleField
derive newtype instance Eq TitleField
derive newtype instance Show TitleField
