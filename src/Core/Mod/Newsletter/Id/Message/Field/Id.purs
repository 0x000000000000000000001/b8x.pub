module Core.Mod.Newsletter.Id.Message.Field.Id where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Id = NewsletterId

newtype NewsletterIdField = NewsletterIdField Id

instance IsField NewsletterIdField Id () where
  name = "Id"

  description = "Newsletter ID"

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: "Newsletter ID"
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NewsletterIdField _
derive newtype instance ReadForeign NewsletterIdField
derive newtype instance WriteForeign NewsletterIdField
derive newtype instance Eq NewsletterIdField
derive newtype instance Show NewsletterIdField
