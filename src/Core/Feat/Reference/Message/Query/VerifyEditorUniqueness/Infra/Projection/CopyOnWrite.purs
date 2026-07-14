module Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyEditorUniquenessProjectionWriteCopyState' = π :: Π "verifyEditorUniquenessProjectionWriteCopyState"

type VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx = (verifyEditorUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx)

type VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx = (verifyEditorUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx)
