module Core.Event.UserEmailChanged.UserEmailChanged where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.UserEmailChanged.Payload (Payload)

data UserEmailChanged

instance IsEvent UserEmailChanged Payload

instance Reflect UserEmailChanged where
  reflectName = "UserEmailChanged"
