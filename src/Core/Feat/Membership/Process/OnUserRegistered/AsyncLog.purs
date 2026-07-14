module Core.Feat.Membership.Process.OnUserRegistered.AsyncLog where

import Proem

import Core.Event.UserRegistered.Payload (Payload)
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Core.Feat.Process.Process (class IsProcess)
import Util.Log (unsafeDebug)
import Util.Type.Type (class Reflect)

data AsyncLogOnUserRegistered

instance Reflect AsyncLogOnUserRegistered where
  reflectName = "AsyncLogOnUserRegistered"

instance IsProcess AsyncLogOnUserRegistered UserRegistered Payload where
  async = true

  handleEvent payload = η $ unsafeDebug $ "(Async) User registered: " <> show payload.id
