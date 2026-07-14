module Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Exception.InvalidArticleFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidArticleFilter = InvalidArticleFilter

type InvalidArticleFilterRow r =
  ("Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Exception.InvalidArticleFilter" ∷ InvalidArticleFilter
  | r
  )

instance Reflect InvalidArticleFilter where
  reflectName = "InvalidArticleFilter"

instance IsLogicException InvalidArticleFilter (InvalidArticleFilterRow r) where
  inj = Variant.inj (π @"Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Exception.InvalidArticleFilter")

instance Translate InvalidArticleFilter where
  translate En _ = "Invalid filter for articles by year"
  translate Fr _ = "Filtre invalide pour les articles par année"
