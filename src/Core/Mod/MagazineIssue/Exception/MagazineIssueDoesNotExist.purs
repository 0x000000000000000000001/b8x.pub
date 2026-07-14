module Core.Mod.MagazineIssue.Exception.MagazineIssueDoesNotExist where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

data MagazineIssueDoesNotExist = MagazineIssueDoesNotExist

type MagazineIssueDoesNotExistRow r =
  ( "Core.Mod.MagazineIssue.Exception.MagazineIssueDoesNotExist" ∷ MagazineIssueDoesNotExist
  | r
  )

instance Reflect MagazineIssueDoesNotExist where
  reflectName = "MagazineIssueDoesNotExist"

instance IsLogicException MagazineIssueDoesNotExist (MagazineIssueDoesNotExistRow r) where
  inj = Variant.inj (π @"Core.Mod.MagazineIssue.Exception.MagazineIssueDoesNotExist")

instance Translate MagazineIssueDoesNotExist where
  translate En _ = "Magazine issue does not exist."
  translate Fr _ = "Le numéro de magazine n'existe pas."
