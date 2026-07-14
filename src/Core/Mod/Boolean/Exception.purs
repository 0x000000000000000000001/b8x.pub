module Core.Mod.Boolean.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type BooleanExceptionRow r = ("Core.Mod.Boolean.Exception" ∷ NotABoolean | r)

data NotABoolean = NotABoolean

instance Reflect NotABoolean where
  reflectName = "NotABoolean"

instance IsLogicException NotABoolean (BooleanExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Boolean.Exception")

instance Translate NotABoolean where
  translate En NotABoolean = "Not a boolean"
  translate Fr NotABoolean = "Ce n'est pas un booléen"
