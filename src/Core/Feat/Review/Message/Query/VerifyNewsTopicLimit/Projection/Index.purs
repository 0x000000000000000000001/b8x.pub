module Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Projection.Index where

import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Projection.Projection (VerifyNewsTopicLimitProjection)

type VerifyNewsTopicLimitProjectionRow r =
  ( verifyNewsTopicLimit :: VerifyNewsTopicLimitProjection
  | r
  )
