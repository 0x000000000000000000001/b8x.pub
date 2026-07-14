module Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Projection.Index where

import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Projection.Projection (VerifyBookUniquenessProjection)

type Row r = ( verifyBookUniqueness ∷ VerifyBookUniquenessProjection | r )
