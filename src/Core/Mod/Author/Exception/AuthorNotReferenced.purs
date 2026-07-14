module Core.Mod.Author.Exception.AuthorNotReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Core.Mod.Author.Id.Id (AuthorId)
import Data.Variant as Variant
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype AuthorNotReferenced = AuthorNotReferenced AuthorId

derive newtype instance Show AuthorNotReferenced

type AuthorNotReferencedRow r =
  ("Core.Mod.Author.Exception.AuthorNotReferenced" ∷ AuthorNotReferenced
  | r
  )

instance Reflect AuthorNotReferenced where
  reflectName = "AuthorNotReferenced"

instance IsLogicException AuthorNotReferenced (AuthorNotReferencedRow r) where
  inj = Variant.inj (π @"Core.Mod.Author.Exception.AuthorNotReferenced")

instance Translate AuthorNotReferenced where
  translate En (AuthorNotReferenced id) = "Author with ID \"" <> toString id <> "\" not referenced"
  translate Fr (AuthorNotReferenced id) = "Auteur avec l'ID \"" <> toString id <> "\" non référencé"
