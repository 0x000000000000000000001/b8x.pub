module Core.Feat.Membership.Message.Command.Index where

import Core.Feat.Membership.Message.Command.ChangeUserEmail.Command (ChangeUserEmail)
import Core.Feat.Membership.Message.Command.RegisterUser.Command (RegisterUser)
import Core.Feat.Membership.Message.Command.UnregisterUser.Command (UnregisterUser)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Command (TrackUserDonated)

type MembershipCommandRow r =
  ( changeUserEmail :: ChangeUserEmail
  , registerUser :: RegisterUser
  , unregisterUser :: UnregisterUser
  , trackUserDonated :: TrackUserDonated
  | r
  )

type MembershipCommandAliasRow :: ∀ k. k -> k
type MembershipCommandAliasRow r = r