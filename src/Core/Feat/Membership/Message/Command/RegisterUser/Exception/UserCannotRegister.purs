module Core.Feat.Membership.Message.Command.RegisterUser.Exception.UserCannotRegister where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data UserCannotRegister = UserCannotRegister

type UserCannotRegisterRow r =
  ("Core.Feat.Membership.Message.Command.RegisterUser.Exception.UserCannotRegister" ∷ UserCannotRegister
  | r
  )

instance Reflect UserCannotRegister where
  reflectName = "UserCannotRegister"

instance IsLogicException UserCannotRegister (UserCannotRegisterRow r) where
  inj = Variant.inj (π @"Core.Feat.Membership.Message.Command.RegisterUser.Exception.UserCannotRegister")

instance Translate UserCannotRegister where
  translate En _ = "User cannot register."
  translate Fr _ = "L'utilisateur ne peut pas s'enregistrer."
