module Core.Mod.Int.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type IntExceptionRow r = ("Core.Mod.Int.Exception" ∷ NotAnInt | r)

data NotAnInt = NotAnInt

instance Reflect NotAnInt where
  reflectName = "NotAnInt"

instance IsLogicException NotAnInt (IntExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Int.Exception")

instance Translate NotAnInt where
  translate En NotAnInt = "Not an integer"
  translate Fr NotAnInt = "Ce n'est pas un nombre entier"
