module Core.Feat.Review.Message.Query.GetFrontPage.Field.TopRightNeed where


import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Message.Field.Field as IsField
import Core.Message.Query.Payload (Need, NeedField)
import Core.Mod.Article.Message.Query.Opt (ArticleOpt, ArticleInnerNeeds)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type TopRightNeed = Need ArticleOpt ArticleInnerNeeds

newtype TopRightNeedField = TopRightNeedField TopRightNeed

description :: String
description = "Top right article need"

instance IsField TopRightNeedField TopRightNeed () where
  name = "TopRightNeed"

  description = description

  presence = IsField.presence @(NeedField ArticleOpt ArticleInnerNeeds)

  sanitize = IsField.sanitize @(NeedField ArticleOpt ArticleInnerNeeds)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).multiline, choices: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).choices
    }

derive instance Newtype TopRightNeedField _
derive newtype instance ReadForeign TopRightNeedField
derive newtype instance WriteForeign TopRightNeedField
derive newtype instance Eq TopRightNeedField
derive newtype instance Show TopRightNeedField
