module Core.Feat.Membership.Exception.Index where

import Core.Feat.Membership.Message.Exception.Index (MembershipMessageExceptionRow)
import Type.Row (type (+))

type MembershipExceptionRow r =
  MembershipMessageExceptionRow
    + r