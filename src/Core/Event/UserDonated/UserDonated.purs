module Core.Event.UserDonated.UserDonated where

import Core.Event.Event (class IsEvent)
import Core.Event.UserDonated.Payload (Payload)
import Util.Type.Type (class Reflect)

data UserDonated

instance IsEvent UserDonated Payload

instance Reflect UserDonated where
  reflectName = "UserDonated"

