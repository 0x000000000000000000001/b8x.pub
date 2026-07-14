module Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Projection.Index where

import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Projection.Projection (VerifyArticleSlugUniquenessProjection)

type VerifyArticleSlugUniquenessProjectionRow r =
  ( verifyArticleSlugUniqueness :: VerifyArticleSlugUniquenessProjection
  | r
  )
