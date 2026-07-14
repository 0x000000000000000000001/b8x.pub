module Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Projection.Index where

import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Projection.Projection (VerifyAuthorUniquenessProjection)

type Row r = ( verifyAuthorUniqueness ∷ VerifyAuthorUniquenessProjection | r )
