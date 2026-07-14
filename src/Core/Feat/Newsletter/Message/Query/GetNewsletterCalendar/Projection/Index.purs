module Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Index where

import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Projection (GetNewsletterCalendarProjection)

type GetNewsletterCalendarProjectionRow r =
  ( getNewsletterCalendar :: GetNewsletterCalendarProjection
  | r
  )
