module Core.Feat.Review.Message.Command.WriteArticle.Field.Profitable where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Profitable = Boolean

newtype ProfitableField = ProfitableField Profitable

description :: String
description = "Profitable?"

instance IsField ProfitableField Profitable () where
  name = "Profitable"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ProfitableField _
derive newtype instance ReadForeign ProfitableField
derive newtype instance WriteForeign ProfitableField
derive newtype instance Eq ProfitableField
derive newtype instance Show ProfitableField
