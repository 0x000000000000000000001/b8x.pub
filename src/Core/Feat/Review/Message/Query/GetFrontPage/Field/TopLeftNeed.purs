module Core.Feat.Review.Message.Query.GetFrontPage.Field.TopLeftNeed where


import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Message.Field.Field as IsField
import Core.Message.Query.Payload (Need, NeedField)
import Core.Mod.Article.Message.Query.Opt (ArticleOpt, ArticleInnerNeeds)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type TopLeftNeed = Need ArticleOpt ArticleInnerNeeds

newtype TopLeftNeedField = TopLeftNeedField TopLeftNeed

description :: String
description = "Top left article need"

instance IsField TopLeftNeedField TopLeftNeed () where
  name = "TopLeftNeed"

  description = description

  presence = IsField.presence @(NeedField ArticleOpt ArticleInnerNeeds)

  sanitize = IsField.sanitize @(NeedField ArticleOpt ArticleInnerNeeds)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).multiline, choices: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).choices
    }

derive instance Newtype TopLeftNeedField _
derive newtype instance ReadForeign TopLeftNeedField
derive newtype instance WriteForeign TopLeftNeedField
derive newtype instance Eq TopLeftNeedField
derive newtype instance Show TopLeftNeedField
