module Core.Feat.Reference.Message.Command.ReferenceBook.Exception.BookCannotBeReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data BookCannotBeReferenced = BookCannotBeReferenced

type BookCannotBeReferencedRow r =
  ("Core.Feat.Reference.Message.Command.ReferenceBook.Exception.BookCannotBeReferenced" ∷ BookCannotBeReferenced
  | r
  )

instance Reflect BookCannotBeReferenced where
  reflectName = "BookCannotBeReferenced"

instance IsLogicException BookCannotBeReferenced (BookCannotBeReferencedRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Command.ReferenceBook.Exception.BookCannotBeReferenced")

instance Translate BookCannotBeReferenced where
  translate En _ = "Book cannot be referenced."
  translate Fr _ = "Le livre ne peut pas être référencé."
