module Core.Feat.Membership.Message.Command.TrackUserDonated.Exception.Index where

import Core.Feat.Membership.Message.Command.TrackUserDonated.Exception.UserDonatedCannotBeTracked (UserDonatedCannotBeTrackedRow)
import Type.Row (type (+))

type TrackUserDonatedExceptionRow r =
  UserDonatedCannotBeTrackedRow
    + r
