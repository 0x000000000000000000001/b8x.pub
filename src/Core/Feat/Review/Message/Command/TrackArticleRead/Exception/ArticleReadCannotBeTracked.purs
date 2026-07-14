module Core.Feat.Review.Message.Command.TrackArticleRead.Exception.ArticleReadCannotBeTracked where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data ArticleReadCannotBeTracked = ArticleReadCannotBeTracked

type ArticleReadCannotBeTrackedRow r =
  ("Core.Feat.Review.Message.Command.TrackArticleRead.Exception.ArticleReadCannotBeTracked" ∷ ArticleReadCannotBeTracked
  | r
  )

instance Reflect ArticleReadCannotBeTracked where
  reflectName = "ArticleReadCannotBeTracked"

instance IsLogicException ArticleReadCannotBeTracked (ArticleReadCannotBeTrackedRow r) where
  inj = Variant.inj (π @"Core.Feat.Review.Message.Command.TrackArticleRead.Exception.ArticleReadCannotBeTracked")

instance Translate ArticleReadCannotBeTracked where
  translate En _ = "Article read cannot be tracked."
  translate Fr _ = "La lecture de l'article ne peut pas être tracée."
