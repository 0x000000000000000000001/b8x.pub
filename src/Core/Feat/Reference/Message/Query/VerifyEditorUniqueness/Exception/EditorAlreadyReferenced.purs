module Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.EditorAlreadyReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data EditorAlreadyReferenced = EditorAlreadyReferenced

type EditorAlreadyReferencedRow r =
  ("Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.EditorAlreadyReferenced" ∷ EditorAlreadyReferenced
  | r
  )

instance Reflect EditorAlreadyReferenced where
  reflectName = "EditorAlreadyReferenced"

instance IsLogicException EditorAlreadyReferenced (EditorAlreadyReferencedRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.EditorAlreadyReferenced")

instance Translate EditorAlreadyReferenced where
  translate En _ = "Editor already referenced."
  translate Fr _ = "Éditeur déjà référencé."
