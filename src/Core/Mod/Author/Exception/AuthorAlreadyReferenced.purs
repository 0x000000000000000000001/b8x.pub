module Core.Mod.Author.Exception.AuthorAlreadyReferenced where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type With =
  { key :: String
  , value :: String
  }

newtype AuthorAlreadyReferenced = AuthorAlreadyReferenced With

type AuthorAlreadyReferencedRow r =
  ( "Core.Mod.Author.Exception.AuthorAlreadyReferenced" ∷ AuthorAlreadyReferenced
  | r
  )

instance Reflect AuthorAlreadyReferenced where
  reflectName = "AuthorAlreadyReferenced"

instance IsLogicException AuthorAlreadyReferenced (AuthorAlreadyReferencedRow r) where
  inj = Variant.inj (π @"Core.Mod.Author.Exception.AuthorAlreadyReferenced")

instance Translate AuthorAlreadyReferenced where
  translate En (AuthorAlreadyReferenced { key, value }) = "Author already referenced with " <> key <> ": " <> value
  translate Fr (AuthorAlreadyReferenced { key, value }) = "Auteur déjà référencé avec " <> key <> " : " <> value
