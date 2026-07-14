module Core.Mod.MagazineIssue.ReleasedAt.Message.Field where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.ReleasedAt.ReleasedAt as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type ReleasedAt = Maybe Base.ReleasedAt

newtype ReleasedAtField = ReleasedAtField ReleasedAt

description :: String
description = "ReleasedAt period of the magazine issue"

instance IsField ReleasedAtField ReleasedAt () where
  name = "ReleasedAt"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ReleasedAtField _
derive newtype instance ReadForeign ReleasedAtField
derive newtype instance WriteForeign ReleasedAtField
derive newtype instance Eq ReleasedAtField
derive newtype instance Show ReleasedAtField
