module Core.Mod.Url.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type UrlExceptionRow r =
  ( "Core.Mod.Url.Exception" ∷ InvalidUrl
  , "Core.Mod.Url.Exception.UrlCannotBeDownloaded" ∷ UrlCannotBeDownloaded
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

newtype UrlCannotBeDownloaded = UrlCannotBeDownloaded String

derive newtype instance Show UrlCannotBeDownloaded
derive newtype instance Eq UrlCannotBeDownloaded

instance Reflect UrlCannotBeDownloaded where
  reflectName = "UrlCannotBeDownloaded"

instance IsLogicException UrlCannotBeDownloaded (UrlExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Url.Exception.UrlCannotBeDownloaded")

instance Translate UrlCannotBeDownloaded where
  translate En (UrlCannotBeDownloaded url) = "The content at URL \"" <> url <> "\" could not be downloaded."
  translate Fr (UrlCannotBeDownloaded url) = "Le contenu à l'URL \"" <> url <> "\" n'a pas pu être téléchargé."
