module Core.Mod.Editor.Exception.EditorNotReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Core.Mod.Editor.Id.Id (EditorId)
import Data.Variant as Variant
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype EditorNotReferenced = EditorNotReferenced EditorId

derive newtype instance Show EditorNotReferenced

type EditorNotReferencedRow r =
  ("Core.Mod.Editor.Exception.EditorNotReferenced" ∷ EditorNotReferenced
  | r
  )

instance Reflect EditorNotReferenced where
  reflectName = "EditorNotReferenced"

instance IsLogicException EditorNotReferenced (EditorNotReferencedRow r) where
  inj = Variant.inj (π @"Core.Mod.Editor.Exception.EditorNotReferenced")

instance Translate EditorNotReferenced where
  translate En (EditorNotReferenced id) = "Editor with ID \"" <> toString id <> "\" not referenced"
  translate Fr (EditorNotReferenced id) = "Éditeur avec l'ID \"" <> toString id <> "\" non référencé"
