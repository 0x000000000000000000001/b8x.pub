module Core.Feat.Newsletter.Infra.Projection.Postgres.Finder.Index where

import Proem

import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Projection as GetNewsletterCalendar
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection as SearchNewsletters
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Projection as VerifyNewsletterUniqueness
import Core.Mod.Projection.Index (PROJECTION_READ_SYNC_PROJECT)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT)
import Infra.Projection.Postgres.Finder.Finder as Base
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionReadFind
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadFind = Base.onProjectionReadFind @GetNewsletterCalendar.Calendar
  ◁ Base.onProjectionReadFind @SearchNewsletters.Newsletter
  ◁ Base.onProjectionReadFind @VerifyNewsletterUniqueness.Newsletter
