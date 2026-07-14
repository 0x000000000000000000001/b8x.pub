module Core.Mod.Id.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type IdExceptionRow r = ("Core.Mod.Id.Exception" ∷ InvalidId | r)

newtype InvalidId = InvalidId String

derive newtype instance Show InvalidId
derive newtype instance Eq InvalidId

instance Reflect InvalidId where
  reflectName = "InvalidId"

instance IsLogicException InvalidId (IdExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Id.Exception")

instance Translate InvalidId where
  translate En (InvalidId id) = "Invalid (ULID) \"" <> id <> "\""
  translate Fr (InvalidId id) = "(ULID) \"" <> id <> "\" invalide"
