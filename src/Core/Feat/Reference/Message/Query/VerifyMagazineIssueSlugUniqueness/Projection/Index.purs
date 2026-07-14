module Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Projection.Index where

import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Projection.Projection (VerifyMagazineIssueSlugUniquenessProjection)

type VerifyMagazineIssueSlugUniquenessProjectionRow r =
  ( verifyMagazineIssueSlugUniqueness :: VerifyMagazineIssueSlugUniquenessProjection
  | r
  )
