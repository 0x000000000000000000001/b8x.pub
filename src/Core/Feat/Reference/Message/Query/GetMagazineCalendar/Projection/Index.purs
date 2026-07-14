module Core.Feat.Reference.Message.Query.GetMagazineCalendar.Projection.Index where

import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Projection.Projection (GetMagazineCalendarProjection)

type GetMagazineCalendarProjectionRow r =
  ( getMagazineCalendar :: GetMagazineCalendarProjection
  | r
  )
