module Core.Feat.Newsletter.Projection.Index where

import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Index (GetNewsletterCalendarProjectionRow)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Projection (GET_NEWSLETTER_CALENDAR_PROJECTION_READ_FIND, GET_NEWSLETTER_CALENDAR_PROJECTION_READ_SYNC_PROJECT, GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_OPS)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Index (SearchNewslettersProjectionRow)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection (SEARCH_NEWSLETTERS_PROJECTION_READ_FIND, SEARCH_NEWSLETTERS_PROJECTION_READ_SYNC_PROJECT, SEARCH_NEWSLETTERS_PROJECTION_WRITE_OPS)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Index (VerifyNewsletterUniquenessProjectionRow)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Projection (VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_FIND, VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT, VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_OPS)
import Type.Row (type (+))

type NewsletterProjectionRow r
  = GetNewsletterCalendarProjectionRow
      + SearchNewslettersProjectionRow
      + VerifyNewsletterUniquenessProjectionRow
      + r

type NEWSLETTER_PROJECTION_WRITE_OPS fx =
  GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_OPS
    + SEARCH_NEWSLETTERS_PROJECTION_WRITE_OPS
    + VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_OPS
    + fx

type NEWSLETTER_PROJECTION_READ_FIND fx =
  GET_NEWSLETTER_CALENDAR_PROJECTION_READ_FIND
    + SEARCH_NEWSLETTERS_PROJECTION_READ_FIND
    + VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_FIND
    + fx

type NEWSLETTER_PROJECTION_READ_SYNC_PROJECT fx =
  GET_NEWSLETTER_CALENDAR_PROJECTION_READ_SYNC_PROJECT
    + SEARCH_NEWSLETTERS_PROJECTION_READ_SYNC_PROJECT
    + VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT
    + fx
