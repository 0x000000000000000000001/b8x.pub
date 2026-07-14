module Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

getNewsletterCalendarProjectionWriteCopyState' = π :: Π "getNewsletterCalendarProjectionWriteCopyState"

type GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_COPY_STATE fx = (getNewsletterCalendarProjectionWriteCopyState :: State CopyOnWrite | fx)

type GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_COPY_PERSIST fx = (getNewsletterCalendarProjectionWriteCopyPersist :: ProjectionPersist | fx)
