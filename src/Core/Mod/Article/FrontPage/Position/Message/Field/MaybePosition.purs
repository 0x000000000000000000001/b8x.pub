module Core.Mod.Article.FrontPage.Position.Message.Field.MaybePosition where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Message.Field.Field as IsField
import Core.Mod.Article.FrontPage.Position.Message.Field as BaseField
import Core.Mod.Article.FrontPage.Position.Position as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

type Position = Maybe Base.Position

newtype PositionField = PositionField Position

description :: String
description = IsField.description @BaseField.PositionField

instance IsField PositionField Position () where
  name = "Position"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli = IsField.cli @BaseField.PositionField

derive instance Newtype PositionField _
derive newtype instance ReadForeign PositionField
derive newtype instance WriteForeign PositionField
derive newtype instance Eq PositionField
derive newtype instance Show PositionField
