module Core.Feat.Membership.Process.OnUserRegistered.AsyncLog2 where

import Proem

import Core.Event.UserRegistered.Payload (Payload)
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Core.Feat.Process.Process (class IsProcess)
import Util.Log (unsafeDebug)
import Util.Type.Type (class Reflect)

data AsyncLog2OnUserRegistered

instance Reflect AsyncLog2OnUserRegistered where
  reflectName = "AsyncLog2OnUserRegistered"

instance IsProcess AsyncLog2OnUserRegistered UserRegistered Payload where
  async = true

  handleEvent payload = ηι >>= \_ ->
    η $ unsafeDebug $ "(Async2) User registered: " <> show payload.id
