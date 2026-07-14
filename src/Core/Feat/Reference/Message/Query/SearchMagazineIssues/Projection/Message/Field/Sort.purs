module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Message.Field.Sort where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Projection (MagazineIssueSortCriteria)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Sort = MagazineIssueSortCriteria

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
