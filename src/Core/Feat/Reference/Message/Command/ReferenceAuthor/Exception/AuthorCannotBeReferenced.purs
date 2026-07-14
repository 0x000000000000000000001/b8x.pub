module Core.Feat.Reference.Message.Command.ReferenceAuthor.Exception.AuthorCannotBeReferenced where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data AuthorCannotBeReferenced = AuthorCannotBeReferenced

type AuthorCannotBeReferencedRow r =
  ("Core.Feat.Reference.Message.Command.ReferenceAuthor.Exception.AuthorCannotBeReferenced" ∷ AuthorCannotBeReferenced
  | r
  )

instance Reflect AuthorCannotBeReferenced where
  reflectName = "AuthorCannotBeReferenced"

instance IsLogicException AuthorCannotBeReferenced (AuthorCannotBeReferencedRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Command.ReferenceAuthor.Exception.AuthorCannotBeReferenced")

instance Translate AuthorCannotBeReferenced where
  translate En _ = "Author cannot be referenced"
  translate Fr _ = "L'auteur ne peut pas être référencé"
