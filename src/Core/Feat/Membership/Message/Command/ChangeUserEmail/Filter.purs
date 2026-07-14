module Core.Feat.Membership.Message.Command.ChangeUserEmail.Filter where

import Proem hiding ((&&), (||))

import Core.Event.Filter (Filter(..), by)
import Core.Event.UserEmailChanged.UserEmailChanged (UserEmailChanged)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Payload (Payload)
import Core.Mod.User.Id.Id (UserId)
import Core.Mod.User.State as User

filter :: Payload -> Filter
filter { user } = filter' user

filter' :: UserId -> Filter
filter' id =
  Or (User.filter id)
    (by @UserEmailChanged @"user" id)
