module Core.Mod.MagazineIssue.Exception.MagazineIssueAlreadyReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data MagazineIssueAlreadyReferenced = MagazineIssueAlreadyReferenced

type MagazineIssueAlreadyReferencedRow r =
  ("Core.Mod.MagazineIssue.Exception.MagazineIssueAlreadyReferenced" ∷ MagazineIssueAlreadyReferenced
  | r
  )

instance Reflect MagazineIssueAlreadyReferenced where
  reflectName = "MagazineIssueAlreadyReferenced"

instance IsLogicException MagazineIssueAlreadyReferenced (MagazineIssueAlreadyReferencedRow r) where
  inj = Variant.inj (π @"Core.Mod.MagazineIssue.Exception.MagazineIssueAlreadyReferenced")

instance Translate MagazineIssueAlreadyReferenced where
  translate En _ = "Magazine issue already referenced."
  translate Fr _ = "Le numéro de magazine est déjà référencé."
