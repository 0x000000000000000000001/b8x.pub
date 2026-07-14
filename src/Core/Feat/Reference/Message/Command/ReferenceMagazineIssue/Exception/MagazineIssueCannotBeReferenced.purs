module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.MagazineIssueCannotBeReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data MagazineIssueCannotBeReferenced = MagazineIssueCannotBeReferenced

type MagazineIssueCannotBeReferencedRow r =
  ("Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.MagazineIssueCannotBeReferenced" ∷ MagazineIssueCannotBeReferenced
  | r
  )

instance Reflect MagazineIssueCannotBeReferenced where
  reflectName = "MagazineIssueCannotBeReferenced"

instance IsLogicException MagazineIssueCannotBeReferenced (MagazineIssueCannotBeReferencedRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.MagazineIssueCannotBeReferenced")

instance Translate MagazineIssueCannotBeReferenced where
  translate En _ = "Magazine issue cannot be referenced."
  translate Fr _ = "Le numéro de magazine ne peut pas être référencé."
