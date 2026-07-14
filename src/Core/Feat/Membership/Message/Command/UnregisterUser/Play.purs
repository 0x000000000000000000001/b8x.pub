module Core.Feat.Membership.Message.Command.UnregisterUser.Play where

import Proem

import Core.Mod.User.State as User
import Core.Event.Event (LoadedEvent)
import Core.Feat.Membership.Message.Command.UnregisterUser.State (State)

play :: State -> LoadedEvent -> State
play s e = s # User.play identity (κ identity) e
