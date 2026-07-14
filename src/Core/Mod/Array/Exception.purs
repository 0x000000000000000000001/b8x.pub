module Core.Mod.Array.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type ArrayExceptionRow r = ("Core.Mod.Array.Exception" ∷ NotAnArray | r)

data NotAnArray = NotAnArray

instance Reflect NotAnArray where
  reflectName = "NotAnArray"

instance IsLogicException NotAnArray (ArrayExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Array.Exception")

instance Translate NotAnArray where
  translate En NotAnArray = "Not a (list) array"
  translate Fr NotAnArray = "Ce n'est pas une liste (tableau)"
