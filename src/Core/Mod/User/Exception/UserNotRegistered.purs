module Core.Mod.User.Exception.UserNotRegistered where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Core.Mod.User.Id.Id (UserId)
import Data.Variant as Variant
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype UserNotRegistered = UserNotRegistered UserId

derive newtype instance Show UserNotRegistered

type UserNotRegisteredRow r =
  ("Core.Mod.User.Exception.UserNotRegistered" ∷ UserNotRegistered
  | r
  )

instance Reflect UserNotRegistered where
  reflectName = "UserNotRegistered"

instance IsLogicException UserNotRegistered (UserNotRegisteredRow r) where
  inj = Variant.inj (π @"Core.Mod.User.Exception.UserNotRegistered")

instance Translate UserNotRegistered where
  translate En (UserNotRegistered id) = "User with ID \"" <> toString id <> "\" not registered"
  translate Fr (UserNotRegistered id) = "Utilisateur avec l'ID \"" <> toString id <> "\" non enregistré"
