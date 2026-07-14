module Core.Feat.Review.Message.Command.WriteArticle.Field.Slug where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize)
import Core.Message.Field.Field as IsField
import Core.Mod.Article.Slug.Message.Field.Slug as BaseField
import Core.Mod.Article.Slug.Slug as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

type Slug = Maybe Base.Slug

newtype SlugField = SlugField Slug

description :: String
description = IsField.description @BaseField.SlugField

instance IsField SlugField Slug () where
  name = "Slug"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = false

  cli = IsField.cli @BaseField.SlugField

derive instance Newtype SlugField _
derive newtype instance ReadForeign SlugField
derive newtype instance WriteForeign SlugField
derive newtype instance Eq SlugField
derive newtype instance Show SlugField
