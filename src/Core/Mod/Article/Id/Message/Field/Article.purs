module Core.Mod.Article.Id.Message.Field.Article where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Article.Id.Message.Field.Util as Util
import Core.Mod.Article.Id.Id (ArticleId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Article = ArticleId

newtype ArticleField = ArticleField Article

instance IsField ArticleField Article () where
  name = "Article"

  description = Util.description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ArticleField _
derive newtype instance ReadForeign ArticleField
derive newtype instance WriteForeign ArticleField
derive newtype instance Eq ArticleField
derive newtype instance Show ArticleField
