module Core.Feat.Review.Message.Query.GetFrontPage.Field.BottomRightNeed where


import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Message.Field.Field as IsField
import Core.Message.Query.Payload (Need, NeedField)
import Core.Mod.Article.Message.Query.Opt (ArticleOpt, ArticleInnerNeeds)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type BottomRightNeed = Need ArticleOpt ArticleInnerNeeds

newtype BottomRightNeedField = BottomRightNeedField BottomRightNeed

description :: String
description = "Bottom right article need"

instance IsField BottomRightNeedField BottomRightNeed () where
  name = "BottomRightNeed"

  description = description

  presence = IsField.presence @(NeedField ArticleOpt ArticleInnerNeeds)

  sanitize = IsField.sanitize @(NeedField ArticleOpt ArticleInnerNeeds)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).multiline, choices: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).choices
    }

derive instance Newtype BottomRightNeedField _
derive newtype instance ReadForeign BottomRightNeedField
derive newtype instance WriteForeign BottomRightNeedField
derive newtype instance Eq BottomRightNeedField
derive newtype instance Show BottomRightNeedField
