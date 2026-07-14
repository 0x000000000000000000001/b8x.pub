module Core.Mod.Email.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type EmailExceptionRow r = ("Core.Mod.Email.Exception" ∷ InvalidEmail | r)

newtype InvalidEmail = InvalidEmail String

derive newtype instance Show InvalidEmail
derive newtype instance Eq InvalidEmail

instance Reflect InvalidEmail where
  reflectName = "InvalidEmail"

instance IsLogicException InvalidEmail (EmailExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Email.Exception")

instance Translate InvalidEmail where
  translate En (InvalidEmail email) = "Invalid email \"" <> email <> "\""
  translate Fr (InvalidEmail email) = "Email \"" <> email <> "\" invalide"
