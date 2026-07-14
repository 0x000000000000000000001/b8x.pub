module Core.Feat.Membership.Process.OnUserRegistered.Log where

import Proem

import Core.Event.UserRegistered.Payload (Payload)
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Core.Feat.Process.Process (class IsProcess)
import Util.Log (unsafeDebug)
import Util.Type.Type (class Reflect)

data LogOnUserRegistered

instance Reflect LogOnUserRegistered where
  reflectName = "LogOnUserRegistered"

instance IsProcess LogOnUserRegistered UserRegistered Payload where
  async = false

  handleEvent payload = η $ unsafeDebug $ "(Sync) User registered: " <> show payload.id
