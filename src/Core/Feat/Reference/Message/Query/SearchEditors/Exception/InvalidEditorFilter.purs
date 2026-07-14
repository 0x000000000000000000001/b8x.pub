module Core.Feat.Reference.Message.Query.SearchEditors.Exception.InvalidEditorFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidEditorFilter = InvalidEditorFilter

type InvalidEditorFilterRow r =
  ("Core.Mod.Editor.Projection.Exception.InvalidEditorFilter" ∷ InvalidEditorFilter
  | r
  )

instance Reflect InvalidEditorFilter where
  reflectName = "InvalidEditorFilter"

instance IsLogicException InvalidEditorFilter (InvalidEditorFilterRow r) where
  inj = Variant.inj (π @"Core.Mod.Editor.Projection.Exception.InvalidEditorFilter")

instance Translate InvalidEditorFilter where
  translate En _ = "Invalid filter for editors"
  translate Fr _ = "Filtre invalide pour les éditeurs"
