module Core.Mod.Image.Exception.ImageCannotBeUploaded where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type ImageCannotBeUploadedRow r =
  ("Core.Mod.Image.Exception.ImageCannotBeUploaded" ∷ ImageCannotBeUploaded
  | r
  )

newtype ImageCannotBeUploaded = ImageCannotBeUploaded String

derive newtype instance Show ImageCannotBeUploaded
derive newtype instance Eq ImageCannotBeUploaded

instance Reflect ImageCannotBeUploaded where
  reflectName = "ImageCannotBeUploaded"

instance IsLogicException ImageCannotBeUploaded (ImageCannotBeUploadedRow r) where
  inj = Variant.inj (π @"Core.Mod.Image.Exception.ImageCannotBeUploaded")

instance Translate ImageCannotBeUploaded where
  translate En (ImageCannotBeUploaded url) = "The image at URL " <> url <> " could not be downloaded or uploaded."
  translate Fr (ImageCannotBeUploaded url) = "L'image à l'URL " <> url <> " n'a pas pu être téléchargée ou transférée."
