module Core.Feat.Membership.Message.Command.ChangeUserEmail.Play where

import Proem hiding ((&&), (||))

import Core.Mod.User.State as User
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.State (State)

play :: State -> LoadedEvent -> State
play _ { event: (UserRegistered { email }) } = User.Registered email

play s { event: (UserEmailChanged { email }) } = s <#> κ email

play _ { event: (UserUnregistered _) } = User.Unregistered

play s _ = s
