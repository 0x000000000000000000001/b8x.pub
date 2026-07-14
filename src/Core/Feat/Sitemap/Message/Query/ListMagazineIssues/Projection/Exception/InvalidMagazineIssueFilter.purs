module Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Exception.InvalidMagazineIssueFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidMagazineIssueFilter = InvalidMagazineIssueFilter

type InvalidMagazineIssueFilterRow r =
  ("Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Exception.InvalidMagazineIssueFilter" ∷ InvalidMagazineIssueFilter
  | r
  )

instance Reflect InvalidMagazineIssueFilter where
  reflectName = "InvalidMagazineIssueFilter"

instance IsLogicException InvalidMagazineIssueFilter (InvalidMagazineIssueFilterRow r) where
  inj = Variant.inj (π @"Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Exception.InvalidMagazineIssueFilter")

instance Translate InvalidMagazineIssueFilter where
  translate En _ = "Invalid filter for magazine issues"
  translate Fr _ = "Filtre invalide pour les revues"
