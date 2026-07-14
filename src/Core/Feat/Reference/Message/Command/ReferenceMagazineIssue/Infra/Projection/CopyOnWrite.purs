module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

referenceMagazineIssueProjectionWriteCopyState' = π :: Π "referenceMagazineIssueProjectionWriteCopyState"

type REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_COPY_STATE fx = (referenceMagazineIssueProjectionWriteCopyState :: State CopyOnWrite | fx)

type REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_COPY_PERSIST fx = (referenceMagazineIssueProjectionWriteCopyPersist :: ProjectionPersist | fx)
