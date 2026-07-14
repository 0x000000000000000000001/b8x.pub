module Core.Mod.Article.FrontPage.Position.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Article.FrontPage.Position.Position as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Position = Base.Position

newtype PositionField = PositionField Position

description :: String
description = "Front page position"

instance IsField PositionField Position () where
  name = "Position"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype PositionField _
derive newtype instance ReadForeign PositionField
derive newtype instance WriteForeign PositionField
derive newtype instance Eq PositionField
derive newtype instance Show PositionField
