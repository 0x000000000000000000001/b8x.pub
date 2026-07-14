module Core.Mod.Book.LegacyIds.Message.Field where

import Data.Maybe (Maybe(..))

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Book.LegacyIds.LegacyIds as Base
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Set as Set
import Data.Newtype (class Newtype)

type LegacyIds = Base.LegacyIds

newtype LegacyIdsField = LegacyIdsField LegacyIds

description :: String
description = "Legacy book IDs"

instance IsField LegacyIdsField LegacyIds () where
  name = "LegacyBookIds"

  description = description

  presence = Optional (η []) "None"

  sanitize json = case defaultSanitize ConsideredMissingSoShouldBeDefault json of
    Intact -> case Control.Monad.Except.runExcept (readImpl json) of
      Right (LegacyIdsField ids) -> Corrected (Array.fromFoldable $ Set.fromFoldable ids)
      Left _ -> Intact
    other -> other

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype LegacyIdsField _
derive newtype instance ReadForeign LegacyIdsField
derive newtype instance WriteForeign LegacyIdsField
derive newtype instance Eq LegacyIdsField
derive newtype instance Show LegacyIdsField
