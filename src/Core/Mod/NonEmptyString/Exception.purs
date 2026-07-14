module Core.Mod.NonEmptyString.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type NonEmptyStringExceptionRow r = ("Core.Mod.NonEmptyString.Exception" ∷ EmptyString | r)

data EmptyString = EmptyString

instance Reflect EmptyString where
  reflectName = "EmptyString"

instance IsLogicException EmptyString (NonEmptyStringExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.NonEmptyString.Exception")

instance Translate EmptyString where
  translate En EmptyString = "Empty string"
  translate Fr EmptyString = "La chaîne de caractères ne peut pas être vide"
