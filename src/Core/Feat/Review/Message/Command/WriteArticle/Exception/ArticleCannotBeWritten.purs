module Core.Feat.Review.Message.Command.WriteArticle.Exception.ArticleCannotBeWritten where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data ArticleCannotBeWritten = ArticleCannotBeWritten

type ArticleCannotBeWrittenRow r =
  ("Core.Feat.Review.Message.Command.WriteArticle.Exception.ArticleCannotBeWritten" ∷ ArticleCannotBeWritten
  | r
  )

instance Reflect ArticleCannotBeWritten where
  reflectName = "ArticleCannotBeWritten"

instance IsLogicException ArticleCannotBeWritten (ArticleCannotBeWrittenRow r) where
  inj = Variant.inj (π @"Core.Feat.Review.Message.Command.WriteArticle.Exception.ArticleCannotBeWritten")

instance Translate ArticleCannotBeWritten where
  translate En _ = "Article cannot be written."
  translate Fr _ = "La revue ne peut pas être écrite."
