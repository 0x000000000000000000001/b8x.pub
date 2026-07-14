module Core.Mod.Article.Identifier.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type IdentifierExceptionRow r = ("Core.Mod.Article.Identifier.Exception" ∷ InvalidArticleIdentifier | r)

newtype InvalidArticleIdentifier = InvalidArticleIdentifier String

derive newtype instance Show InvalidArticleIdentifier
derive newtype instance Eq InvalidArticleIdentifier

instance Reflect InvalidArticleIdentifier where
  reflectName = "InvalidArticleIdentifier"

instance IsLogicException InvalidArticleIdentifier (IdentifierExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.Identifier.Exception")

instance Translate InvalidArticleIdentifier where
  translate En (InvalidArticleIdentifier id) = "Invalid article identifier format: \"" <> id <> "\""
  translate Fr (InvalidArticleIdentifier id) = "Format d'identifiant d'article invalide : \"" <> id <> "\""
