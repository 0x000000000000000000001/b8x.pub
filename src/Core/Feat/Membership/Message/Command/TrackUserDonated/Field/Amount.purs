module Core.Feat.Membership.Message.Command.TrackUserDonated.Field.Amount where

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Amount = Int

newtype AmountField = AmountField Amount

derive instance Newtype AmountField _
derive newtype instance ReadForeign AmountField
derive newtype instance WriteForeign AmountField

description :: String
description = "The amount of the donation in cents."

instance IsField AmountField Amount () where
  name = "Amount"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }
