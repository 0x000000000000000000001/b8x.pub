module Core.Mod.Infra.Projection.Postgres.Index
  ( interpretProjectionWriteCopyPersist
  , interpretProjectionWriteOps
  , interpretProjectionReadSyncProject
  , interpretProjectionReadSyncProjectWithNoop
  ) where

import Proem

import Core.Mod.Projection.Index (PROJECTION_WRITE_OPS, PROJECTION_READ_SYNC_PROJECT)
import Core.Feat.Sitemap.Infra.Projection.Postgres.Index as Sitemap
import Core.Feat.Review.Infra.Projection.Postgres.Index as Review
import Core.Feat.Reference.Infra.Projection.Postgres.Index as Reference
import Core.Feat.Newsletter.Infra.Projection.Postgres.Index as FeatNewsletter
import Core.Feat.Membership.Infra.Projection.Postgres.Index as Membership
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (PROJECTION_WRITE_COPY_STATE, PROJECTION_WRITE_COPY_PERSIST)
import Run (interpret, send, AFF, EFFECT, Run)
import Type.Row (type (+))
import Util.Run.Router as Router

interpretProjectionWriteOps
  :: ∀ fx a
   . Run (PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
  -> Run (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
interpretProjectionWriteOps =
  interpret
    ( Router.build
        ( Review.onProjectionWriteOps
            ◁ Sitemap.onProjectionWriteOps
            ◁ FeatNewsletter.onProjectionWriteOps
            ◁ Reference.onProjectionWriteOps
            ◁ Membership.onProjectionWriteOps
            $ Router.empty
        )
        send
    )

interpretProjectionWriteCopyPersist
  :: ∀ fx a
   . Run (PROJECTION_WRITE_COPY_PERSIST + PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
  -> Run (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
interpretProjectionWriteCopyPersist =
  interpret
    ( Router.build
        ( Review.onProjectionWriteCopyPersist
            ◁ Sitemap.onProjectionWriteCopyPersist
            ◁ FeatNewsletter.onProjectionWriteCopyPersist
            ◁ Reference.onProjectionWriteCopyPersist
            ◁ Membership.onProjectionWriteCopyPersist
            $ Router.empty
        )
        send
    )

interpretProjectionReadSyncProject
  :: ∀ fx a
   . Run (PROJECTION_READ_SYNC_PROJECT + PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) a
  -> Run (PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) a
interpretProjectionReadSyncProject =
  interpret
    ( Router.build
        ( Review.onProjectionReadSyncProject
            ◁ Sitemap.onProjectionReadSyncProject
            ◁ FeatNewsletter.onProjectionReadSyncProject
            ◁ Reference.onProjectionReadSyncProject
            ◁ Membership.onProjectionReadSyncProject
            $ Router.empty
        )
        send
    )

interpretProjectionReadSyncProjectWithNoop
  :: ∀ fx a
   . Run (PROJECTION_READ_SYNC_PROJECT + fx) a
  -> Run fx a
interpretProjectionReadSyncProjectWithNoop =
  interpret
    ( Router.build
        ( Review.onProjectionReadSyncProjectWithNoop
            ◁ Sitemap.onProjectionReadSyncProjectWithNoop
            ◁ FeatNewsletter.onProjectionReadSyncProjectWithNoop
            ◁ Reference.onProjectionReadSyncProjectWithNoop
            ◁ Membership.onProjectionReadSyncProjectWithNoop
            $ Router.empty
        )
        send
    )
