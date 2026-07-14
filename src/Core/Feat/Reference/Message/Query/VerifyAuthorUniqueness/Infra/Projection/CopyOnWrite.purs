module Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyAuthorUniquenessProjectionWriteCopyState' = π :: Π "verifyAuthorUniquenessProjectionWriteCopyState"

type VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx = (verifyAuthorUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx)

type VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx = (verifyAuthorUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx)
