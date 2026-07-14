module Core.Mod.Article.Illustrations.Inputs.Caption.Message.Field where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Html.Html (NonEmptyHtml)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Caption = Maybe NonEmptyHtml

newtype CaptionField = CaptionField Caption

description :: String
description = "Illustration caption"

instance IsField CaptionField Caption () where
  name = "Caption"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CaptionField _
derive newtype instance ReadForeign CaptionField
derive newtype instance WriteForeign CaptionField
derive newtype instance Eq CaptionField
derive newtype instance Show CaptionField
