module Core.Mod.Article.Sources.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Mod.Html.Message.Field (defaultHtmlSanitize)
import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultShouldSanitizeInner)
import Core.Mod.Article.Sources.Sources as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Sources = Base.Sources

newtype SourcesField = SourcesField Sources

description :: String
description = "Article sources"

instance IsField SourcesField Sources () where
  name = "Sources"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultHtmlSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype SourcesField _
derive newtype instance ReadForeign SourcesField
derive newtype instance WriteForeign SourcesField
derive newtype instance Eq SourcesField
derive newtype instance Show SourcesField
