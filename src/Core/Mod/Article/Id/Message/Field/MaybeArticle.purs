module Core.Mod.Article.Id.Message.Field.MaybeArticle where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Article.Id.Message.Field.Util as Util
import Core.Mod.Article.Id.Id (ArticleId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Article = Maybe ArticleId

newtype ArticleField = ArticleField Article

instance IsField ArticleField Article () where
  name = "Article"

  description = Util.description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

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
