module Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Index where

import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Projection (VerifyNewsletterUniquenessProjection)

type VerifyNewsletterUniquenessProjectionRow r =
  ( verifyNewsletterUniqueness :: VerifyNewsletterUniquenessProjection
  | r
  )
