module Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Projection.Index where

import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Projection.Projection (VerifyEditorUniquenessProjection)

type VerifyEditorUniquenessProjectionRow r =
  ( verifyEditorUniqueness ∷ VerifyEditorUniquenessProjection
  | r
  )
