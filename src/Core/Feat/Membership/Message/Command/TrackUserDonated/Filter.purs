module Core.Feat.Membership.Message.Command.TrackUserDonated.Filter where

import Core.Event.Filter (Filter, by)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Payload (Payload)
import Core.Event.UserDonated.UserDonated (UserDonated)
import Proem

filter :: Payload -> Filter
filter { email, donatedAt } = by @UserDonated @"thirdPartyEmail" email && by @UserDonated @"donatedAt" donatedAt
