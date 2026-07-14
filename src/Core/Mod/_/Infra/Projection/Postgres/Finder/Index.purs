module Core.Mod.Infra.Projection.Postgres.Finder.Index where

import Proem

import Core.Mod.Projection.Index (PROJECTION_READ_FIND, PROJECTION_READ_SYNC_PROJECT)
import Core.Feat.Sitemap.Infra.Projection.Postgres.Finder.Index as Sitemap
import Core.Feat.Review.Infra.Projection.Postgres.Finder.Index as Review
import Core.Feat.Newsletter.Infra.Projection.Postgres.Finder.Index as NewsletterFeat
import Core.Feat.Reference.Infra.Projection.Postgres.Finder.Index as Reference
import Core.Feat.Membership.Infra.Projection.Postgres.Finder.Index as Membership
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT)
import Run (interpret, send, AFF, EFFECT, Run)
import Type.Row (type (+))
import Util.Run.Router as Router

interpretProjectionReadFind
  :: ∀ fx a
   . Run (PROJECTION_READ_FIND + PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
  -> Run (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
interpretProjectionReadFind =
  interpret
    ( Router.build
        ( Review.onProjectionReadFind
            ◁ NewsletterFeat.onProjectionReadFind
            ◁ Reference.onProjectionReadFind
            ◁ Membership.onProjectionReadFind
            ◁ Sitemap.onProjectionReadFind
            $ Router.empty
        )
        send
    )
