module Core.Feat.Membership.Message.Exception.Index where

import Core.Feat.Membership.Message.Command.Exception.Index (MembershipCommandExceptionRow)
import Type.Row (type (+))

type MembershipMessageExceptionRow r =
  MembershipCommandExceptionRow
    + r