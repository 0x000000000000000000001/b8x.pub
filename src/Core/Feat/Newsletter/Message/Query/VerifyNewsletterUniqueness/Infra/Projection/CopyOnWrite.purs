module Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyNewsletterUniquenessProjectionWriteCopyState' = π :: Π "verifyNewsletterUniquenessProjectionWriteCopyState"

type VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_COPY_STATE fx = (verifyNewsletterUniquenessProjectionWriteCopyState :: State CopyOnWrite | fx)

type VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST fx = (verifyNewsletterUniquenessProjectionWriteCopyPersist :: ProjectionPersist | fx)
