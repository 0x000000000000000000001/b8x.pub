module Core.Feat.Reference.Message.Command.ReferenceEditor.Exception.EditorCannotBeReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data EditorCannotBeReferenced = EditorCannotBeReferenced

type EditorCannotBeReferencedRow r =
  ("Core.Feat.Reference.Message.Command.ReferenceEditor.Exception.EditorCannotBeReferenced" ∷ EditorCannotBeReferenced
  | r
  )

instance Reflect EditorCannotBeReferenced where
  reflectName = "EditorCannotBeReferenced"

instance IsLogicException EditorCannotBeReferenced (EditorCannotBeReferencedRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Command.ReferenceEditor.Exception.EditorCannotBeReferenced")

instance Translate EditorCannotBeReferenced where
  translate En _ = "Editor cannot be referenced"
  translate Fr _ = "L'éditeur ne peut pas être référencé"
