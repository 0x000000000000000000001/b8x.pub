module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Exception.InvalidCustomSectionFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidCustomSectionFilter = InvalidCustomSectionFilter

type InvalidCustomSectionFilterRow r =
  ("Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Exception.InvalidCustomSectionFilter" ∷ InvalidCustomSectionFilter
  | r
  )

instance Reflect InvalidCustomSectionFilter where
  reflectName = "InvalidCustomSectionFilter"

instance IsLogicException InvalidCustomSectionFilter (InvalidCustomSectionFilterRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Exception.InvalidCustomSectionFilter")

instance Translate InvalidCustomSectionFilter where
  translate En _ = "Invalid filter for custom sections"
  translate Fr _ = "Filtre invalide pour les sections personnalisées"
