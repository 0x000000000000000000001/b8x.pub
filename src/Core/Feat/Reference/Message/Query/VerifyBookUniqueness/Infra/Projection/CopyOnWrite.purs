module Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyBookUniquenessProjectionWriteCopyState' = π :: Π "verifyBookUniquenessProjectionWriteCopyState"

type VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx = (verifyBookUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx)

type VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx = (verifyBookUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx)
