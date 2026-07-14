module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Exception.InvalidNewsletterFilter where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

data InvalidNewsletterFilter = InvalidNewsletterFilter

type InvalidNewsletterFilterRow r =
  ( "Core.Feat.Newsletter.Message.Query.SearchNewsletters.Exception.InvalidNewsletterFilter" ∷ InvalidNewsletterFilter
  | r
  )

instance Reflect InvalidNewsletterFilter where
  reflectName = "InvalidNewsletterFilter"

instance IsLogicException InvalidNewsletterFilter (InvalidNewsletterFilterRow r) where
  inj = Variant.inj (π @"Core.Feat.Newsletter.Message.Query.SearchNewsletters.Exception.InvalidNewsletterFilter")

instance Translate InvalidNewsletterFilter where
  translate En _ = "Invalid newsletter filter."
  translate Fr _ = "Filtre de newsletter invalide."
