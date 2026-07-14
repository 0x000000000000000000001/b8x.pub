module Core.Mod.Book.Exception.BookNotReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Core.Mod.Book.Id.Id (BookId)
import Data.Variant as Variant
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype BookNotReferenced = BookNotReferenced BookId

derive newtype instance Show BookNotReferenced

type BookNotReferencedRow r =
  ("Core.Mod.Book.Exception.BookNotReferenced" ∷ BookNotReferenced
  | r
  )

instance Reflect BookNotReferenced where
  reflectName = "BookNotReferenced"

instance IsLogicException BookNotReferenced (BookNotReferencedRow r) where
  inj = Variant.inj (π @"Core.Mod.Book.Exception.BookNotReferenced")

instance Translate BookNotReferenced where
  translate En (BookNotReferenced id) = "Book with ID \"" <> toString id <> "\" not referenced"
  translate Fr (BookNotReferenced id) = "Livre avec l'ID \"" <> toString id <> "\" non référencé"
