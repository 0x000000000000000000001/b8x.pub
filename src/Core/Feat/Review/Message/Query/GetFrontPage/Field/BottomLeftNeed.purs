module Core.Feat.Review.Message.Query.GetFrontPage.Field.BottomLeftNeed where


import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Message.Field.Field as IsField
import Core.Message.Query.Payload (Need, NeedField)
import Core.Mod.Article.Message.Query.Opt (ArticleOpt, ArticleInnerNeeds)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type BottomLeftNeed = Need ArticleOpt ArticleInnerNeeds

newtype BottomLeftNeedField = BottomLeftField BottomLeftNeed

description :: String
description = "Bottom left article need"

instance IsField BottomLeftNeedField BottomLeftNeed () where
  name = "BottomLeftNeed"

  description = description

  presence = IsField.presence @(NeedField ArticleOpt ArticleInnerNeeds)

  sanitize = IsField.sanitize @(NeedField ArticleOpt ArticleInnerNeeds)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).multiline, choices: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).choices
    }

derive instance Newtype BottomLeftNeedField _
derive newtype instance ReadForeign BottomLeftNeedField
derive newtype instance WriteForeign BottomLeftNeedField
derive newtype instance Eq BottomLeftNeedField
derive newtype instance Show BottomLeftNeedField
