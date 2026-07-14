module Core.Mod.Time.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type TimeExceptionRow r = ("Core.Mod.Time.Exception" ∷ InvalidInstant | r)

data InvalidInstant = InvalidInstant

instance Reflect InvalidInstant where
  reflectName = "InvalidInstant"

instance IsLogicException InvalidInstant (TimeExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Time.Exception")

instance Translate InvalidInstant where
  translate En InvalidInstant = "Invalid instant format"
  translate Fr InvalidInstant = "Format de date invalide"
