module Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Exception.InvalidArticleYearFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidArticleYearFilter = InvalidArticleYearFilter

type InvalidArticleYearFilterRow r =
  ( "Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Exception.InvalidArticleYearFilter" ∷ InvalidArticleYearFilter
  | r
  )

instance Reflect InvalidArticleYearFilter where
  reflectName = "InvalidArticleYearFilter"

instance IsLogicException InvalidArticleYearFilter (InvalidArticleYearFilterRow r) where
  inj = Variant.inj (π @"Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Exception.InvalidArticleYearFilter")

instance Translate InvalidArticleYearFilter where
  translate En _ = "Invalid filter for article years"
  translate Fr _ = "Filtre invalide pour les années d'articles"
