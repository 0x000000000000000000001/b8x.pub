module Core.Feat.Membership.Infra.Projection.Postgres.Finder.Index where

import Proem

import Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Projection as GetUserAccount
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
onProjectionReadFind = Base.onProjectionReadFind @GetUserAccount.Account
  ◁ Base.onProjectionReadFind @GetUserAccount.Donation
