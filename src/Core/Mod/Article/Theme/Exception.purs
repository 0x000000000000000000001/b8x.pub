module Core.Mod.Article.Theme.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

newtype InvalidTheme = InvalidTheme String

derive newtype instance Show InvalidTheme

type ThemeExceptionRow r =
  ("Core.Mod.Article.Theme.Exception" ∷ InvalidTheme
  | r
  )

instance Reflect InvalidTheme where
  reflectName = "InvalidTheme"

instance IsLogicException InvalidTheme (ThemeExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.Theme.Exception")

instance Translate InvalidTheme where
  translate En (InvalidTheme str) = "Invalid article theme: " <> str
  translate Fr (InvalidTheme str) = "Thème d'article invalide : " <> str
