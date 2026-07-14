module Core.Mod.Infra.Projection.CopyOnWrite.Index where

import Proem
import Core.Feat.Sitemap.Infra.Projection.CopyOnWrite.Index as Sitemap
import Core.Feat.Sitemap.Infra.Projection.CopyOnWrite.Index (SITEMAP_PROJECTION_WRITE_COPY_STATE, SITEMAP_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Review.Infra.Projection.CopyOnWrite.Index as Review
import Core.Feat.Review.Infra.Projection.CopyOnWrite.Index (REVIEW_PROJECTION_WRITE_COPY_STATE, REVIEW_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Reference.Infra.Projection.CopyOnWrite.Index as Reference
import Core.Feat.Reference.Infra.Projection.CopyOnWrite.Index (REFERENCE_PROJECTION_WRITE_COPY_STATE, REFERENCE_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Newsletter.Infra.Projection.CopyOnWrite.Index as FeatNewsletter
import Core.Feat.Newsletter.Infra.Projection.CopyOnWrite.Index (NEWSLETTER_PROJECTION_WRITE_COPY_STATE, NEWSLETTER_PROJECTION_WRITE_COPY_PERSIST) as FeatNewsletterTypes
import Core.Feat.Membership.Infra.Projection.CopyOnWrite.Index as Membership
import Core.Feat.Membership.Infra.Projection.CopyOnWrite.Index (MEMBERSHIP_PROJECTION_WRITE_COPY_STATE, MEMBERSHIP_PROJECTION_WRITE_COPY_PERSIST)
import Run (Run)
import Type.Row (type (+))

evalProjectionWriteCopyState
  :: ∀ fx a
   . Run (PROJECTION_WRITE_COPY_STATE + fx) a
  -> Run fx a
evalProjectionWriteCopyState =
  Review.evalProjectionWriteCopyState
    ▷ Sitemap.evalProjectionWriteCopyState
    ▷ FeatNewsletter.evalProjectionWriteCopyState
    ▷ Reference.evalProjectionWriteCopyState
    ▷ Membership.evalProjectionWriteCopyState

type PROJECTION_WRITE_COPY_STATE fx =
  REVIEW_PROJECTION_WRITE_COPY_STATE
    + SITEMAP_PROJECTION_WRITE_COPY_STATE
    + FeatNewsletterTypes.NEWSLETTER_PROJECTION_WRITE_COPY_STATE
    + REFERENCE_PROJECTION_WRITE_COPY_STATE
    + MEMBERSHIP_PROJECTION_WRITE_COPY_STATE
    + fx

type PROJECTION_WRITE_COPY_PERSIST fx =
  REVIEW_PROJECTION_WRITE_COPY_PERSIST
    + SITEMAP_PROJECTION_WRITE_COPY_PERSIST
    + FeatNewsletterTypes.NEWSLETTER_PROJECTION_WRITE_COPY_PERSIST
    + REFERENCE_PROJECTION_WRITE_COPY_PERSIST
    + MEMBERSHIP_PROJECTION_WRITE_COPY_PERSIST
    + fx

type PROJECTION_WRITE_COPY fx =
  PROJECTION_WRITE_COPY_STATE
    + PROJECTION_WRITE_COPY_PERSIST
    + fx
