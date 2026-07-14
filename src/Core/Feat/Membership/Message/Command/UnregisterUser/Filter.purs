module Core.Feat.Membership.Message.Command.UnregisterUser.Filter where

import Proem hiding ((&&))

import Core.Mod.User.State as User
import Core.Event.Filter (Filter)
import Core.Feat.Membership.Message.Command.UnregisterUser.Payload (Payload)

filter :: Payload -> Filter
filter { user } = User.filter user
