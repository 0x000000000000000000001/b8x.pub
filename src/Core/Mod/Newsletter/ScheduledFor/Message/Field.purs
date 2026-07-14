module Core.Mod.Newsletter.ScheduledFor.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Time.Instant (Instant)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type ScheduledFor = Instant

newtype ScheduledForField = ScheduledForField ScheduledFor

instance IsField ScheduledForField ScheduledFor () where
  name = "ScheduledFor"

  description = "Newsletter scheduled date"

  presence = Required
  
  sanitize _ = Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: "Newsletter scheduled date"
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ScheduledForField _
derive newtype instance ReadForeign ScheduledForField
derive newtype instance WriteForeign ScheduledForField
derive newtype instance Eq ScheduledForField
derive newtype instance Show ScheduledForField
