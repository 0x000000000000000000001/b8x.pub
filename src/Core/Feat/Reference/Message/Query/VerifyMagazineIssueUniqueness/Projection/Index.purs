module Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Projection.Index where

import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Projection.Projection (VerifyMagazineIssueUniquenessProjection)

type VerifyMagazineIssueUniquenessProjectionRow r =
  ( verifyMagazineIssueUniqueness :: VerifyMagazineIssueUniquenessProjection
  | r
  )
