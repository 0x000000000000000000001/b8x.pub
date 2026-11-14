module Core.Feat.Reference.Message.Command.ReferenceAuthor.Field.BiographyUrl where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Url.Url as Base
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Yoga.JSON (class ReadForeign, class WriteForeign)

type BiographyUrl = Maybe Base.Url

newtype BiographyUrlField = BiographyUrlField BiographyUrl

description :: String
description = "Biography URL (.docx file)"

instance IsField BiographyUrlField BiographyUrl () where
  name = "Biography"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype BiographyUrlField _
derive newtype instance ReadForeign BiographyUrlField
derive newtype instance WriteForeign BiographyUrlField
derive newtype instance Eq BiographyUrlField
derive newtype instance Show BiographyUrlField
