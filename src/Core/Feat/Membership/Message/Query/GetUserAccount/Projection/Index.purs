module Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Index where

import Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Projection (GetUserAccountProjection)

type GetUserAccountProjectionRow r =
  ( getUserAccount :: GetUserAccountProjection
  | r
  )
