module Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyArticleSlugUniquenessProjectionWriteCopyState' = π :: Π "verifyArticleSlugUniquenessProjectionWriteCopyState"

type VERIFY_ARTICLE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx =
  ( verifyArticleSlugUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx )

type VERIFY_ARTICLE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx =
  ( verifyArticleSlugUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx )
