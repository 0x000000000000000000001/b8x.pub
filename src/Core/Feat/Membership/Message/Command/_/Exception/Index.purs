module Core.Feat.Membership.Message.Command.Exception.Index where

import Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken (EmailAlreadyTakenRow)
import Core.Feat.Membership.Message.Command.RegisterUser.Exception.Index (RegisterUserExceptionRow)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Exception.Index (TrackUserDonatedExceptionRow)
import Type.Row (type (+))

type MembershipCommandExceptionRow r =
  RegisterUserExceptionRow
    + EmailAlreadyTakenRow
    + TrackUserDonatedExceptionRow
    + r