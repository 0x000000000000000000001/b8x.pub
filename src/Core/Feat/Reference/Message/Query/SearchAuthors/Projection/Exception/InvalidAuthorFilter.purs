module Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.InvalidAuthorFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidAuthorFilter = InvalidAuthorFilter

type InvalidAuthorFilterRow r =
  ("Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.InvalidAuthorFilter" ∷ InvalidAuthorFilter
  | r
  )

instance Reflect InvalidAuthorFilter where
  reflectName = "InvalidAuthorFilter"

instance IsLogicException InvalidAuthorFilter (InvalidAuthorFilterRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.InvalidAuthorFilter")

instance Translate InvalidAuthorFilter where
  translate En _ = "Invalid filter for authors"
  translate Fr _ = "Filtre invalide pour les auteurs"
