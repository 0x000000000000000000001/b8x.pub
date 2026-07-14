module Core.Mod.MagazineIssue.LegacyId.Message.Field where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.LegacyId.LegacyId as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type LegacyId = Base.LegacyId

newtype LegacyIdField = LegacyIdField LegacyId

description :: String
description = "Legacy magazine isue ID"

instance IsField LegacyIdField LegacyId () where
  name = "LegacyId"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype LegacyIdField _
derive newtype instance ReadForeign LegacyIdField
derive newtype instance WriteForeign LegacyIdField
derive newtype instance Eq LegacyIdField
derive newtype instance Show LegacyIdField
