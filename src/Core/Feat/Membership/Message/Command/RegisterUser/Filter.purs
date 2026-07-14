module Core.Feat.Membership.Message.Command.RegisterUser.Filter where

import Proem hiding ((&&), (||))

import Core.Event.Filter (Filter(..))
import Core.Feat.Membership.Message.Command.RegisterUser.Payload (Payload)
import Core.Feat.Membership.Message.Command.Service.VerifyEmailUniqueness as VerifyEmailUniqueness
import Core.Mod.User.State as User

filter :: Payload -> Filter
filter { id, email } =
  Or (User.filter id)
    (VerifyEmailUniqueness.neededEventsFilter email)
