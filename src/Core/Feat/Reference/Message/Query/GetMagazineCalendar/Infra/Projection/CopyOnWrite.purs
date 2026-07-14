module Core.Feat.Reference.Message.Query.GetMagazineCalendar.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

getMagazineCalendarProjectionWriteCopyState' = π :: Π "getMagazineCalendarProjectionWriteCopyState"

type GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_COPY_STATE fx = (getMagazineCalendarProjectionWriteCopyState :: State CopyOnWrite | fx)

type GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_COPY_PERSIST fx = (getMagazineCalendarProjectionWriteCopyPersist :: ProjectionPersist | fx)
