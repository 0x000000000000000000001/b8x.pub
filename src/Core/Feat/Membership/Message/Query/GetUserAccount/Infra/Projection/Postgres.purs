module Core.Feat.Membership.Message.Query.GetUserAccount.Infra.Projection.Postgres where

import Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Projection (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS, GetUserAccountProjection)
import Core.Feat.Membership.Message.Query.GetUserAccount.Infra.Projection.CopyOnWrite (GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_PERSIST)
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
onProjectionWriteOps = Base.onProjectionWriteOps @GetUserAccountProjection

onProjectionWriteCopyPersist
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteCopyPersist = Base.onProjectionWriteCopyPersist @GetUserAccountProjection

onProjectionReadSyncProject
  :: ∀ fx' a
   . RouterBuilder (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadSyncProject = Base.onProjectionReadSyncProject @GetUserAccountProjection

onProjectionReadSyncProjectWithNoop
  :: ∀ fx' a
   . RouterBuilder fx' a
  -> RouterBuilder fx' a
onProjectionReadSyncProjectWithNoop = Base.onProjectionReadSyncProjectWithNoop @GetUserAccountProjection
