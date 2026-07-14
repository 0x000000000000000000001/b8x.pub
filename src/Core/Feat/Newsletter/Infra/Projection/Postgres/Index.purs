module Core.Feat.Newsletter.Infra.Projection.Postgres.Index where

import Proem

import Core.Feat.Newsletter.Projection.Index (NEWSLETTER_PROJECTION_WRITE_OPS)
import Core.Feat.Newsletter.Infra.Projection.CopyOnWrite.Index (NEWSLETTER_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Projection (GetNewsletterCalendarProjection)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection (SearchNewslettersProjection)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Projection (VerifyNewsletterUniquenessProjection)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (PROJECTION_WRITE_COPY_STATE)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT)
import Infra.Projection.Postgres.Projection as Base
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionWriteOps
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteOps = Base.onProjectionWriteOps @GetNewsletterCalendarProjection
  ◁ Base.onProjectionWriteOps @SearchNewslettersProjection
  ◁ Base.onProjectionWriteOps @VerifyNewsletterUniquenessProjection

onProjectionWriteCopyPersist
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteCopyPersist = Base.onProjectionWriteCopyPersist @GetNewsletterCalendarProjection
  ◁ Base.onProjectionWriteCopyPersist @SearchNewslettersProjection
  ◁ Base.onProjectionWriteCopyPersist @VerifyNewsletterUniquenessProjection

onProjectionReadSyncProject
  :: ∀ fx' a
   . RouterBuilder (NEWSLETTER_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + NEWSLETTER_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (NEWSLETTER_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + NEWSLETTER_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadSyncProject = Base.onProjectionReadSyncProject @GetNewsletterCalendarProjection
  ◁ Base.onProjectionReadSyncProject @SearchNewslettersProjection
  ◁ Base.onProjectionReadSyncProject @VerifyNewsletterUniquenessProjection

onProjectionReadSyncProjectWithNoop
  :: ∀ fx' a
   . RouterBuilder fx' a
  -> RouterBuilder fx' a
onProjectionReadSyncProjectWithNoop = Base.onProjectionReadSyncProjectWithNoop @GetNewsletterCalendarProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @SearchNewslettersProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyNewsletterUniquenessProjection
