module Core.Mod.Projection.Finder.Expectation.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Projection.Finder.Expectation.Expectation as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)
import Util.Type.String.ToString (toString)

type Expectation = Base.Expectation

newtype ExpectationField = ExpectationField Expectation

description :: String
description = "Indicates if the search query should"

instance IsField ExpectationField Expectation () where
  name = "Expectation"

  description = description

  presence = Optional (η Base.QuickNothingBetterThanSlowerSomething) (Base.QuickNothingBetterThanSlowerSomething # toString)

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ExpectationField _
derive newtype instance ReadForeign ExpectationField
derive newtype instance WriteForeign ExpectationField
derive newtype instance Eq ExpectationField
derive newtype instance Show ExpectationField
