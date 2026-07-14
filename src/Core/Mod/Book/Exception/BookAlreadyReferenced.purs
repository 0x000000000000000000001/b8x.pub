module Core.Mod.Book.Exception.BookAlreadyReferenced where

import Proem
import Yoga.JSON as Yoga.JSON

import Core.Exception.Exception (class IsLogicException)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Book.Name.Name (Name)
import Core.Mod.Editor.Id.Id (EditorId)
import Yoga.JSON (writeImpl)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype BookAlreadyReferenced = BookAlreadyReferenced
  (Maybe
      { name :: Name
      , authors :: Array AuthorId
      , editor :: Maybe EditorId
      }
  )

derive instance Generic BookAlreadyReferenced _
derive instance Eq BookAlreadyReferenced
derive instance Ord BookAlreadyReferenced

type BookAlreadyReferencedRow r =
  ("Core.Mod.Book.Exception.BookAlreadyReferenced" ∷ BookAlreadyReferenced
  | r
  )

instance Reflect BookAlreadyReferenced where
  reflectName = "BookAlreadyReferenced"

instance IsLogicException BookAlreadyReferenced (BookAlreadyReferencedRow r) where
  inj = Variant.inj (π @"Core.Mod.Book.Exception.BookAlreadyReferenced")

instance Translate BookAlreadyReferenced where
  translate En (BookAlreadyReferenced Nothing) = "Book already referenced"
  translate En (BookAlreadyReferenced (Just { name, authors, editor })) = "Book '" <> toString name <> "' already referenced (Authors: " <> (authors <#> toString # writeImpl # Yoga.JSON.writeJSON) <> ", Editor: " <> (editor <#> toString # writeImpl # Yoga.JSON.writeJSON) <> ")"

  translate Fr (BookAlreadyReferenced Nothing) = "Livre déjà référencé"
  translate Fr (BookAlreadyReferenced (Just { name, authors, editor })) = "Livre '" <> toString name <> "' déjà référencé (Auteurs: " <> (authors <#> toString # writeImpl # Yoga.JSON.writeJSON) <> ", Editeur: " <> (editor <#> toString # writeImpl # Yoga.JSON.writeJSON) <> ")"

