module Core.Feat.Membership.Message.Command.UnregisterUser.Decide where

import Proem hiding (append)

import Core.Mod.User.State as User
import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Membership.Message.Command.UnregisterUser.Payload (Payload)
import Core.Feat.Membership.Message.Command.UnregisterUser.State (State)
import Core.Mod.User.Exception.UserNotRegistered (UserNotRegistered(..))
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide User.NotRegisteredYet { user } = throw $ UserNotRegistered user
decide User.Unregistered { user } = throw $ UserNotRegistered user
decide (User.Registered _) { user } = η [ UserUnregistered { user } ]
