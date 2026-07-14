module Core.Feat.Membership.Message.Command.UnregisterUser.State where

import Proem

import Core.Mod.User.State as User
import Core.Feat.Membership.Message.Command.UnregisterUser.Payload as UnregisterUser

type State = User.State Ɩ

initialState :: UnregisterUser.Payload -> State
initialState _ = User.initialState
