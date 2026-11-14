module Core.Feat.Review.Message.Command.WriteArticle.Field.ContentUrl where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultShouldSanitizeInner)
import Core.Mod.Url.Url as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type ContentUrl = Base.Url

newtype ContentUrlField = ContentUrlField ContentUrl

description :: String
description = "Content URL (.docx file)"

instance IsField ContentUrlField ContentUrl () where
  name = "Content"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ContentUrlField _
derive newtype instance ReadForeign ContentUrlField
derive newtype instance WriteForeign ContentUrlField
derive newtype instance Eq ContentUrlField
derive newtype instance Show ContentUrlField
