module Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.IllustrationRequired where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type IllustrationRequired = Boolean

newtype IllustrationRequiredField = IllustrationRequiredField Boolean

description :: String
description = "Illustration required"

instance IsField IllustrationRequiredField Boolean () where
  name = "IllustrationRequired"
  
  description = description
  
  presence = Required
  
  sanitize = κ Intact
  
  shouldSanitizeInner = defaultShouldSanitizeInner

  cli = { description, multiline: false , choices: Nothing
    }

derive instance Newtype IllustrationRequiredField _
derive newtype instance ReadForeign IllustrationRequiredField
derive newtype instance WriteForeign IllustrationRequiredField
derive newtype instance Eq IllustrationRequiredField
derive newtype instance Show IllustrationRequiredField
