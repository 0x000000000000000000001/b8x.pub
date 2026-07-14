module Core.Feat.Reference.Message.Command.ReferenceBook.Field.CoverUrl where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultShouldSanitizeInner)
import Core.Mod.Url.Url as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type Cover = Maybe Base.Url

newtype CoverField = CoverField Cover

description :: String
description = "Cover URL"

instance IsField CoverField Cover () where
  name = "Cover"

  description = description

  presence = defaultMaybePresence

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CoverField _
derive newtype instance ReadForeign CoverField
derive newtype instance WriteForeign CoverField
derive newtype instance Eq CoverField
derive newtype instance Show CoverField
