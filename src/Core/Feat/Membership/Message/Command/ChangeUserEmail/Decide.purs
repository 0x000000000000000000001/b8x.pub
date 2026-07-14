module Core.Feat.Membership.Message.Command.ChangeUserEmail.Decide where

import Proem hiding ((&&), (||))

import Core.Mod.User.State as User
import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Payload (Payload)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.State (State)
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
decide (User.Registered oldEmail) { user, email } =
  oldEmail == email
    ? (η [])
    ↔ η [ UserEmailChanged { user, email } ]
