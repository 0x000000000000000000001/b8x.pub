module Core.Mod.Article.Id.Message.Field.After where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Article.Id.Id (ArticleId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type AfterArticle = Maybe ArticleId

newtype AfterArticleField = AfterArticleField AfterArticle

description :: String
description = "After article ID"

instance IsField AfterArticleField AfterArticle () where
  name = "Article"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype AfterArticleField _
derive newtype instance ReadForeign AfterArticleField
derive newtype instance WriteForeign AfterArticleField
derive newtype instance Eq AfterArticleField
derive newtype instance Show AfterArticleField
