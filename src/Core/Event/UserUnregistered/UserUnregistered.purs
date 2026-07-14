module Core.Event.UserUnregistered.UserUnregistered where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.UserUnregistered.Payload (Payload)

data UserUnregistered

instance IsEvent UserUnregistered Payload

instance Reflect UserUnregistered where
  reflectName = "UserUnregistered"
