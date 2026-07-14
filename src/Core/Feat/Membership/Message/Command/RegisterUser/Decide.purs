module Core.Feat.Membership.Message.Command.RegisterUser.Decide where

import Proem hiding (append)

import Core.Mod.User.State as User
import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Membership.Message.Command.RegisterUser.Payload (Payload)
import Core.Feat.Membership.Message.Command.RegisterUser.State (State)
import Core.Mod.User.Exception.UserAlreadyRegistered (UserAlreadyRegistered(..))
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide User.NotRegisteredYet { id, email } = η [ UserRegistered { id, email } ]
decide User.Unregistered { id, email } = η [ UserRegistered { id, email } ]
decide (User.Registered existingUserId) _ = throw (UserAlreadyRegistered { existingUserId })
