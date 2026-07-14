module Core.Mod.MagazineIssue.Slug.Message.Field.Slug where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Slug.Slug as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Slug = Base.Slug

newtype SlugField = SlugField Slug

description :: String
description = "Magazine issue slug"

instance IsField SlugField Slug () where
  name = "Slug"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype SlugField _
derive newtype instance ReadForeign SlugField
derive newtype instance WriteForeign SlugField
derive newtype instance Eq SlugField
derive newtype instance Show SlugField
