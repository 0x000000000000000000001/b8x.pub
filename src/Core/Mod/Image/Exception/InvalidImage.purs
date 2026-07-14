module Core.Mod.Image.Exception.InvalidImage where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type InvalidImageRow r =
  ("Core.Mod.Image.Exception.InvalidImage" ∷ InvalidImage
  | r
  )

newtype InvalidImage = InvalidImage String

derive newtype instance Show InvalidImage
derive newtype instance Eq InvalidImage

instance Reflect InvalidImage where
  reflectName = "InvalidImage"

instance IsLogicException InvalidImage (InvalidImageRow r) where
  inj = Variant.inj (π @"Core.Mod.Image.Exception.InvalidImage")

instance Translate InvalidImage where
  translate En (InvalidImage text) = "Invalid image " <> text
  translate Fr (InvalidImage text) = "Image " <> text <> " invalide"
