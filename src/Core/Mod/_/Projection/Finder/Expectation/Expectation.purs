module Core.Mod.Projection.Finder.Expectation.Expectation
  ( Expectation(..)
  ) where

import Proem

import Control.Monad.Except (runExcept)
import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Util.Json.String (readStringImpl, writeStringImpl)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (class FromString, class ToString)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Yoga.JSON as Yoga.JSON

-- | E.g. QuickNothingBetterThanSlowerSomething means that we prefer quick empty results
-- |over slower non-empty results.
data Expectation
  = QuickNothingBetterThanSlowerSomething
  | SlowerSomethingBetterThanQuickNothing

derive instance Eq Expectation
derive instance Generic Expectation _
derive instance Ord Expectation

instance Show Expectation where
  show = genericShow

instance WriteForeign Expectation where
  writeImpl = writeStringImpl

instance ReadForeign Expectation where
  readImpl = readStringImpl

instance ToString Expectation where
  toString = show

instance FromString Expectation where
  fromString "QuickNothingBetterThanSlowerSomething" = Just QuickNothingBetterThanSlowerSomething
  fromString "SlowerSomethingBetterThanQuickNothing" = Just SlowerSomethingBetterThanQuickNothing
  fromString _ = Nothing

instance Random Expectation where
  random = pure QuickNothingBetterThanSlowerSomething

instance IsRefinedType Expectation (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case runExcept (Yoga.JSON.readImpl json) of
    Right e -> Right e
    Left err -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error: err }
