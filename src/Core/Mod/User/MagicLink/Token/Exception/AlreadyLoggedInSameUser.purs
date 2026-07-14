module Core.Mod.User.MagicLink.Token.Exception.AlreadyLoggedInSameUser where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (Language(..), class Translate)
import Util.Type.Type (class Reflect)

newtype AlreadyLoggedInSameUser = AlreadyLoggedInSameUser {}

type AlreadyLoggedInSameUserRow r =
  ( "Core.Mod.User.MagicLink.Token.Exception.AlreadyLoggedInSameUser" ∷ AlreadyLoggedInSameUser
  | r
  )

instance Reflect AlreadyLoggedInSameUser where
  reflectName = "AlreadyLoggedInSameUser"

instance IsLogicException AlreadyLoggedInSameUser (AlreadyLoggedInSameUserRow r) where
  inj = Variant.inj (π @"Core.Mod.User.MagicLink.Token.Exception.AlreadyLoggedInSameUser")

instance Translate AlreadyLoggedInSameUser where
  translate En _ = "You are already logged in."
  translate Fr _ = "Vous êtes déjà connecté(e)."
