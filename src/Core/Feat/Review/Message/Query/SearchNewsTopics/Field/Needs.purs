module Core.Feat.Review.Message.Query.SearchNewsTopics.Field.Needs where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Message.Query.Payload (Need(..), NeedField)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Needs =
  { id :: Need Ɩ Ɩ
  , searchInput :: Need Ɩ Ɩ
  }

defaultNeeds :: Needs
defaultNeeds =
  { id: NotNeeded
  , searchInput: NotNeeded
  }

type NeedsFieldChildren =
  (id :: NeedField Ɩ Ɩ
  , searchInput :: NeedField Ɩ Ɩ
  )

newtype NeedsField = NeedsField Needs

description :: String
description = "News topic needs"

instance
  IsField
    NeedsField
    Needs
    NeedsFieldChildren
  where
  name = "Needs"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NeedsField _
derive newtype instance ReadForeign NeedsField
derive newtype instance WriteForeign NeedsField
derive newtype instance Eq NeedsField
derive newtype instance Show NeedsField
