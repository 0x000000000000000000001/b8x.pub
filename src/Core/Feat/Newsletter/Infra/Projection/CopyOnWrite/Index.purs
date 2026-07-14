module Core.Feat.Newsletter.Infra.Projection.CopyOnWrite.Index where

import Proem

import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Infra.Projection.CopyOnWrite (GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_COPY_PERSIST, GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_COPY_STATE, getNewsletterCalendarProjectionWriteCopyState')
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Infra.Projection.CopyOnWrite (SEARCH_NEWSLETTERS_PROJECTION_WRITE_COPY_PERSIST, SEARCH_NEWSLETTERS_PROJECTION_WRITE_COPY_STATE, searchNewslettersProjectionWriteCopyState')
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Infra.Projection.CopyOnWrite (VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyNewsletterUniquenessProjectionWriteCopyState')
import Data.Map as Map
import Run (Run)
import Run.State (evalStateAt)
import Type.Row (type (+))

evalProjectionWriteCopyState
  :: ∀ fx a
   . Run (NEWSLETTER_PROJECTION_WRITE_COPY_STATE + fx) a
  -> Run fx a
evalProjectionWriteCopyState =
  evalStateAt getNewsletterCalendarProjectionWriteCopyState' Map.empty
    ▷ evalStateAt searchNewslettersProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyNewsletterUniquenessProjectionWriteCopyState' Map.empty

type NEWSLETTER_PROJECTION_WRITE_COPY_STATE fx =
  GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_COPY_STATE
    + SEARCH_NEWSLETTERS_PROJECTION_WRITE_COPY_STATE
    + VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + fx

type NEWSLETTER_PROJECTION_WRITE_COPY_PERSIST fx =
  GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_COPY_PERSIST
    + SEARCH_NEWSLETTERS_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + fx

type NEWSLETTER_PROJECTION_WRITE_COPY fx =
  NEWSLETTER_PROJECTION_WRITE_COPY_STATE
    + NEWSLETTER_PROJECTION_WRITE_COPY_PERSIST
    + fx
