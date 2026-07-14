module Core.Feat.Membership.Process.OnUserRegistered.Log2 where

import Proem

import Core.Event.UserRegistered.Payload (Payload)
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Core.Feat.Process.Process (class IsProcess)
import Util.Log (unsafeDebug)
import Util.Type.Type (class Reflect)

data Log2OnUserRegistered

instance Reflect Log2OnUserRegistered where
  reflectName = "Log2OnUserRegistered"

instance IsProcess Log2OnUserRegistered UserRegistered Payload where
  async = false

  handleEvent payload = η $ unsafeDebug $ "(Sync2) User registered: " <> show payload.id
