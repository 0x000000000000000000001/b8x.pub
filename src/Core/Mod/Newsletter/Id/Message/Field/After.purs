module Core.Mod.Newsletter.Id.Message.Field.After where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type AfterNewsletter = Maybe NewsletterId

newtype AfterNewsletterField = AfterNewsletterField AfterNewsletter

description :: String
description = "After newsletter ID"

instance IsField AfterNewsletterField AfterNewsletter () where
  name = "Newsletter"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype AfterNewsletterField _
derive newtype instance ReadForeign AfterNewsletterField
derive newtype instance WriteForeign AfterNewsletterField
derive newtype instance Eq AfterNewsletterField
derive newtype instance Show AfterNewsletterField
