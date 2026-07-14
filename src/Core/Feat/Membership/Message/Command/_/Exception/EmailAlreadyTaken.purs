module Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

import Core.Mod.User.Id.Id (UserId)

newtype EmailAlreadyTaken = EmailAlreadyTaken { existingUserId :: UserId }

type EmailAlreadyTakenRow r =
  ("Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken" ∷ EmailAlreadyTaken
  | r
  )

instance Reflect EmailAlreadyTaken where
  reflectName = "EmailAlreadyTaken"

instance IsLogicException EmailAlreadyTaken (EmailAlreadyTakenRow r) where
  inj = Variant.inj (π @"Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken")

instance Translate EmailAlreadyTaken where
  translate En _ = "Email is already taken."
  translate Fr _ = "Cette adresse e-mail est déjà utilisée."
