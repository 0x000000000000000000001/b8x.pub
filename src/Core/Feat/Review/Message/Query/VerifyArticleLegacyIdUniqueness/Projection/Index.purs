module Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Projection.Index where

import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Projection.Projection (VerifyArticleLegacyIdUniquenessProjection)

type VerifyArticleLegacyIdUniquenessProjectionRow r =
  ( verifyArticleLegacyIdUniqueness :: VerifyArticleLegacyIdUniquenessProjection
  | r
  )
