module Core.Mod.Token.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type TokenExceptionRow r = ("Core.Mod.Token.Exception" ∷ InvalidToken | r)

newtype InvalidToken = InvalidToken String

derive newtype instance Show InvalidToken
derive newtype instance Eq InvalidToken

instance Reflect InvalidToken where
  reflectName = "InvalidToken"

instance IsLogicException InvalidToken (TokenExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Token.Exception")

instance Translate InvalidToken where
  translate En (InvalidToken token) = "Invalid token \"" <> token <> "\""
  translate Fr (InvalidToken token) = "Token \"" <> token <> "\" invalide"
