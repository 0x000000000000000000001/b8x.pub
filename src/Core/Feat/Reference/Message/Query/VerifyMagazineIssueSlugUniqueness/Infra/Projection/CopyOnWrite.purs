module Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyMagazineIssueSlugUniquenessProjectionWriteCopyState' = π :: Π "verifyMagazineIssueSlugUniquenessProjectionWriteCopyState"

type VERIFY_MAGAZINE_ISSUE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx = (verifyMagazineIssueSlugUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx)

type VERIFY_MAGAZINE_ISSUE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx = (verifyMagazineIssueSlugUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx)
