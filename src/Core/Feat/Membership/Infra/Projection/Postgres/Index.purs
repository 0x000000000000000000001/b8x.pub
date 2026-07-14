module Core.Feat.Membership.Infra.Projection.Postgres.Index where

import Core.Feat.Membership.Projection.Index (MEMBERSHIP_PROJECTION_WRITE_OPS)
import Core.Feat.Membership.Infra.Projection.CopyOnWrite.Index (MEMBERSHIP_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Membership.Message.Query.GetUserAccount.Infra.Projection.Postgres as GetUserAccount
import Core.Mod.Infra.Projection.CopyOnWrite.Index (PROJECTION_WRITE_COPY_STATE)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT)
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionWriteOps
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteOps =
  GetUserAccount.onProjectionWriteOps

onProjectionWriteCopyPersist
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteCopyPersist =
  GetUserAccount.onProjectionWriteCopyPersist

onProjectionReadSyncProject
  :: ∀ fx' a
   . RouterBuilder (MEMBERSHIP_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + MEMBERSHIP_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (MEMBERSHIP_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + MEMBERSHIP_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadSyncProject =
  GetUserAccount.onProjectionReadSyncProject

onProjectionReadSyncProjectWithNoop
  :: ∀ fx' a
   . RouterBuilder fx' a
  -> RouterBuilder fx' a
onProjectionReadSyncProjectWithNoop =
  GetUserAccount.onProjectionReadSyncProjectWithNoop
