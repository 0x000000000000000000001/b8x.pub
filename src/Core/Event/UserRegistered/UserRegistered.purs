module Core.Event.UserRegistered.UserRegistered where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.UserRegistered.Payload (Payload)

data UserRegistered

instance IsEvent UserRegistered Payload

instance Reflect UserRegistered where
  reflectName = "UserRegistered"
