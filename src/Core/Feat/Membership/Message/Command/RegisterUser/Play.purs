module Core.Feat.Membership.Message.Command.RegisterUser.Play where

import Proem

import Core.Mod.User.State as User
import Core.Event.Event (LoadedEvent)
import Core.Feat.Membership.Message.Command.RegisterUser.State (State)

play :: State -> LoadedEvent -> State
play s e = s # User.playUserId identity (κ identity) e
