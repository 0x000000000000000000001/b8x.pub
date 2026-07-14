module Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Projection.Index where

import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Projection.Projection (VerifyNewsRelatedArticleWhitelistLimitProjection)

type VerifyNewsRelatedArticleWhitelistLimitProjectionRow r =
  ( verifyNewsRelatedArticleWhitelistLimit :: VerifyNewsRelatedArticleWhitelistLimitProjection
  | r
  )
