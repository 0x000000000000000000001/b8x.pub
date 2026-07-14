module Core.Mod.User.Exception.UserAlreadyRegistered where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)
import Core.Mod.User.Id.Id (UserId)

newtype UserAlreadyRegistered = UserAlreadyRegistered { existingUserId :: UserId }

type UserAlreadyRegisteredRow r =
  ("Core.Mod.User.Exception.UserAlreadyRegistered" ∷ UserAlreadyRegistered
  | r
  )

instance Reflect UserAlreadyRegistered where
  reflectName = "UserAlreadyRegistered"

instance IsLogicException UserAlreadyRegistered (UserAlreadyRegisteredRow r) where
  inj = Variant.inj (π @"Core.Mod.User.Exception.UserAlreadyRegistered")

instance Translate UserAlreadyRegistered where
  translate En _ = "User already registered"
  translate Fr _ = "Utilisateur déjà enregistré"
