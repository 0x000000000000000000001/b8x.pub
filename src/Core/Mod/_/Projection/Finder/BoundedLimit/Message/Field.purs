module Core.Mod.Projection.Finder.BoundedLimit.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..), defaultLimit, defaultLimit_, maxLimit_, minLimit_)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)
import Util.Type.String.ToString (toString)

newtype BoundedLimitField = BoundedLimitField BoundedLimit

description :: String
description = "Limit of results. That will be automatically clamped between " <> (minLimit_ # toString) <> " and " <> (maxLimit_ # toString)

instance IsField BoundedLimitField BoundedLimit () where
  name = "BoundedLimit"

  description = description

  presence = Optional (η defaultLimit) (defaultLimit_ # toString)

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype BoundedLimitField _
derive newtype instance ReadForeign BoundedLimitField
derive newtype instance WriteForeign BoundedLimitField
derive newtype instance Eq BoundedLimitField
derive newtype instance Show BoundedLimitField
