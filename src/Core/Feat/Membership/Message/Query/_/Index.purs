module Core.Feat.Membership.Message.Query.Index where

import Core.Feat.Membership.Message.Query.GetUserAccount.Query (GetUserAccount)

type MembershipQueryRow r =
  (getUserAccount :: GetUserAccount
  | r
  )