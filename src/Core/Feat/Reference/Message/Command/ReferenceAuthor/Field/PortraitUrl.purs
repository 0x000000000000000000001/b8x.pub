module Core.Feat.Reference.Message.Command.ReferenceAuthor.Field.PortraitUrl where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultShouldSanitizeInner)
import Core.Mod.Url.Url as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Portrait = Maybe Base.Url

newtype PortraitField = PortraitField Portrait

description :: String
description = "Portrait URL"

instance IsField PortraitField Portrait () where
  name = "Portrait"

  description = description

  presence = defaultMaybePresence

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype PortraitField _
derive newtype instance ReadForeign PortraitField
derive newtype instance WriteForeign PortraitField
derive newtype instance Eq PortraitField
derive newtype instance Show PortraitField
