module Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Message.Field.Sort where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Projection (ArticleSortCriteria)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Sort = ArticleSortCriteria

newtype SortField = SortField Sort

description :: String
description = "Sort"

instance IsField SortField Sort () where
  name = "Sort"

  description = description

  presence = Optional (η []) "None"

  sanitize = defaultSanitize (Corrected [])

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype SortField _
derive newtype instance Eq SortField
derive newtype instance Show SortField
derive newtype instance ReadForeign SortField
derive newtype instance WriteForeign SortField
