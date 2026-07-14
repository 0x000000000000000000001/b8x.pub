module Core.Feat.Membership.Message.Command.ChangeUserEmail.State where

import Proem hiding ((&&), (||))

import Core.Mod.User.State as User
import Core.Mod.Email.Email (Email)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Payload as ChangeUserEmail

type State = User.State Email

initialState :: ChangeUserEmail.Payload -> State
initialState _ = User.NotRegisteredYet
