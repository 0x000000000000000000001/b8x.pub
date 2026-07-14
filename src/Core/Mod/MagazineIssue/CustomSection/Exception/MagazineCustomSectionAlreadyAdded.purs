module Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionAlreadyAdded where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

data MagazineCustomSectionAlreadyAdded = MagazineCustomSectionAlreadyAdded

type MagazineCustomSectionAlreadyAddedRow r =
  ( "Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionAlreadyAdded" ∷ MagazineCustomSectionAlreadyAdded
  | r
  )

instance Reflect MagazineCustomSectionAlreadyAdded where
  reflectName = "MagazineCustomSectionAlreadyAdded"

instance IsLogicException MagazineCustomSectionAlreadyAdded (MagazineCustomSectionAlreadyAddedRow r) where
  inj = Variant.inj (π @"Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionAlreadyAdded")

instance Translate MagazineCustomSectionAlreadyAdded where
  translate En _ = "Magazine custom section already added."
  translate Fr _ = "La section sur-mesure du numéro de magazine est déjà ajoutée."
