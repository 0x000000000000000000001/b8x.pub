module Core.Feat.Review.Message.Query.GetFrontPage.Field.Needs where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Feat.Review.Message.Query.GetFrontPage.Field.BottomLeftNeed (BottomLeftNeed, BottomLeftNeedField)
import Core.Feat.Review.Message.Query.GetFrontPage.Field.BottomRightNeed (BottomRightNeed, BottomRightNeedField)
import Core.Feat.Review.Message.Query.GetFrontPage.Field.CenterNeed (CenterNeed, CenterNeedField)
import Core.Feat.Review.Message.Query.GetFrontPage.Field.TopLeftNeed (TopLeftNeed, TopLeftNeedField)
import Core.Feat.Review.Message.Query.GetFrontPage.Field.TopRightNeed (TopRightNeed, TopRightNeedField)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Needs =
  { topLeft :: TopLeftNeed
  , topRight :: TopRightNeed
  , center :: CenterNeed
  , bottomLeft :: BottomLeftNeed
  , bottomRight :: BottomRightNeed
  }

newtype NeedsField = NeedsField Needs

type NeedsFieldChildren =
  (topLeft :: TopLeftNeedField
  , topRight :: TopRightNeedField
  , center :: CenterNeedField
  , bottomLeft :: BottomLeftNeedField
  , bottomRight :: BottomRightNeedField
  )

description :: String
description = "Front page article needs"

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
