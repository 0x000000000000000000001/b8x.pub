module Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyMagazineIssueUniquenessProjectionWriteCopyState' = π :: Π "verifyMagazineIssueUniquenessProjectionWriteCopyState"

type VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx = (verifyMagazineIssueUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx)

type VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx = (verifyMagazineIssueUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx)
