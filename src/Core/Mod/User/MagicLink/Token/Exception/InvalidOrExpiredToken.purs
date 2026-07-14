module Core.Mod.User.MagicLink.Token.Exception.InvalidOrExpiredToken where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (Language(..), class Translate)
import Util.Type.Type (class Reflect)

newtype InvalidOrExpiredToken = InvalidOrExpiredToken {}

type InvalidOrExpiredTokenRow r =
  ( "Core.Mod.User.MagicLink.Token.Exception.InvalidOrExpiredToken" ∷ InvalidOrExpiredToken
  | r
  )

instance Reflect InvalidOrExpiredToken where
  reflectName = "InvalidOrExpiredToken"

instance IsLogicException InvalidOrExpiredToken (InvalidOrExpiredTokenRow r) where
  inj = Variant.inj (π @"Core.Mod.User.MagicLink.Token.Exception.InvalidOrExpiredToken")

instance Translate InvalidOrExpiredToken where
  translate En _ = "Invalid or expired magic link token."
  translate Fr _ = "Lien magique invalide ou expiré."
