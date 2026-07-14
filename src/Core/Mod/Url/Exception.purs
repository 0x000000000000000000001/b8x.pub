module Core.Mod.Url.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type UrlExceptionRow r =
  ("Core.Mod.Url.Exception" ∷ InvalidUrl
  | r
  )

newtype InvalidUrl = InvalidUrl String

derive newtype instance Show InvalidUrl
derive newtype instance Eq InvalidUrl

instance Reflect InvalidUrl where
  reflectName = "InvalidUrl"

instance IsLogicException InvalidUrl (UrlExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Url.Exception")

instance Translate InvalidUrl where
  translate En (InvalidUrl str) = "Invalid URL \"" <> str <> "\""
  translate Fr (InvalidUrl str) = "URL invalide \"" <> str <> "\""
