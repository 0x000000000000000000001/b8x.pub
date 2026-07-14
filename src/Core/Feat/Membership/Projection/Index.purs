module Core.Feat.Membership.Projection.Index where

import Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Index (GetUserAccountProjectionRow)
import Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Projection (GET_USER_ACCOUNT_PROJECTION_READ_FIND, GET_USER_ACCOUNT_PROJECTION_READ_SYNC_PROJECT, GET_USER_ACCOUNT_PROJECTION_WRITE_OPS)
import Type.Row (type (+))

type MembershipProjectionRow r
  = GetUserAccountProjectionRow
      + r

type MEMBERSHIP_PROJECTION_WRITE_OPS fx =
  GET_USER_ACCOUNT_PROJECTION_WRITE_OPS
    + fx

type MEMBERSHIP_PROJECTION_READ_FIND fx =
  GET_USER_ACCOUNT_PROJECTION_READ_FIND
    + fx

type MEMBERSHIP_PROJECTION_READ_SYNC_PROJECT fx =
  GET_USER_ACCOUNT_PROJECTION_READ_SYNC_PROJECT
    + fx
