module Core.Feat.Membership.Message.Command.TrackUserDonated.Exception.UserDonatedCannotBeTracked where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data UserDonatedCannotBeTracked = UserDonatedCannotBeTracked

type UserDonatedCannotBeTrackedRow r =
  ("Core.Feat.Membership.Message.Command.TrackUserDonated.Exception.UserDonatedCannotBeTracked" ∷ UserDonatedCannotBeTracked
  | r
  )

instance Reflect UserDonatedCannotBeTracked where
  reflectName = "UserDonatedCannotBeTracked"

instance IsLogicException UserDonatedCannotBeTracked (UserDonatedCannotBeTrackedRow r) where
  inj = Variant.inj (π @"Core.Feat.Membership.Message.Command.TrackUserDonated.Exception.UserDonatedCannotBeTracked")

instance Translate UserDonatedCannotBeTracked where
  translate En _ = "User donation cannot be tracked."
  translate Fr _ = "Le don de l'utilisateur ne peut pas être tracé."
