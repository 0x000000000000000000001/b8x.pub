module Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Infra.Projection.CopyOnWrite where

import Proem
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyArticleLegacyIdUniquenessProjectionWriteCopyState' = π :: Π "verifyArticleLegacyIdUniquenessProjectionWriteCopyState"

type VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx
  = ( verifyArticleLegacyIdUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx )

type VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx
  = ( verifyArticleLegacyIdUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx )
