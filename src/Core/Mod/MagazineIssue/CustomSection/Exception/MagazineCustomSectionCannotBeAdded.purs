module Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionCannotBeAdded where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

data MagazineCustomSectionCannotBeAdded = MagazineCustomSectionCannotBeAdded

type MagazineCustomSectionCannotBeAddedRow r =
  ( "Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionCannotBeAdded" ∷ MagazineCustomSectionCannotBeAdded
  | r
  )

instance Reflect MagazineCustomSectionCannotBeAdded where
  reflectName = "MagazineCustomSectionCannotBeAdded"

instance IsLogicException MagazineCustomSectionCannotBeAdded (MagazineCustomSectionCannotBeAddedRow r) where
  inj = Variant.inj (π @"Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionCannotBeAdded")

instance Translate MagazineCustomSectionCannotBeAdded where
  translate En _ = "Magazine custom section cannot be added."
  translate Fr _ = "La section sur-mesure du numéro de magazine ne peut pas être ajoutée."
