module Core.Mod.MagazineIssue.Slug.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type SlugExceptionRow r = ("Core.Mod.MagazineIssue.Slug.Exception" ∷ InvalidSlug | r )

newtype InvalidSlug = InvalidSlug String

derive newtype instance Show InvalidSlug
derive newtype instance Eq InvalidSlug

instance Reflect InvalidSlug where
  reflectName = "InvalidSlug"

instance IsLogicException InvalidSlug (SlugExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.MagazineIssue.Slug.Exception")

instance Translate InvalidSlug where
  translate En (InvalidSlug slug) = "Invalid slug format: \"" <> slug <> "\""
  translate Fr (InvalidSlug slug) = "Format de slug invalide : \"" <> slug <> "\""
