module Core.Feat.Review.Message.Query.GetFrontPage.Field.CenterNeed where


import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Message.Field.Field as IsField
import Core.Message.Query.Payload (Need, NeedField)
import Core.Mod.Article.Message.Query.Opt (ArticleOpt, ArticleInnerNeeds)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type CenterNeed = Need ArticleOpt ArticleInnerNeeds

newtype CenterNeedField = CenterNeedField CenterNeed

description :: String
description = "CenterNeed article need"

instance IsField CenterNeedField CenterNeed () where
  name = "CenterNeed"

  description = description

  presence = IsField.presence @(NeedField ArticleOpt ArticleInnerNeeds)

  sanitize = IsField.sanitize @(NeedField ArticleOpt ArticleInnerNeeds)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).multiline, choices: (IsField.cli @(NeedField ArticleOpt ArticleInnerNeeds)).choices
    }

derive instance Newtype CenterNeedField _
derive newtype instance ReadForeign CenterNeedField
derive newtype instance WriteForeign CenterNeedField
derive newtype instance Eq CenterNeedField
derive newtype instance Show CenterNeedField
