module Core.Mod.Book.Projection.Exception.InvalidBookFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidBookFilter = InvalidBookFilter

type InvalidBookFilterRow r =
  ("Core.Mod.Book.Projection.Exception.InvalidBookFilter" ∷ InvalidBookFilter
  | r
  )

instance Reflect InvalidBookFilter where
  reflectName = "InvalidBookFilter"

instance IsLogicException InvalidBookFilter (InvalidBookFilterRow r) where
  inj = Variant.inj (π @"Core.Mod.Book.Projection.Exception.InvalidBookFilter")

instance Translate InvalidBookFilter where
  translate En _ = "Invalid filter for books"
  translate Fr _ = "Filtre invalide pour les livres"
