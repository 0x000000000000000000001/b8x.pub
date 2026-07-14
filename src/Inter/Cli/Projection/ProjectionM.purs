module Inter.Cli.Projection.ProjectionM where

import Proem

import Config.InternalConfig (internalConfig)
import Core.Mod.Projection.Projection (class IsProjection)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_STORE_CLIENT, READER_POSTGRES_EDGE_CLIENT, runPostgresStoreClientReader, runPostgresEdgeClientReader)
import Infra.Client.Postgres.Postgres as Postgres
import Core.Mod.Infra.Projection.CopyOnWrite.Index (evalProjectionWriteCopyState)
import Core.Mod.Infra.Projection.Index as Base
import Core.Mod.Infra.Projection.Postgres.Index (interpretProjectionReadSyncProjectWithNoop, interpretProjectionWriteCopyPersist, interpretProjectionWriteOps)
import Core.Mod.Infra.Projection.Postgres.Finder.Index (interpretProjectionReadFind)
import Effect.Aff (Aff)
import Run (AFF, EFFECT, Run, runBaseAff')
import Util.Signal (READER_SIGNAL_REF, SignalRef, runSignalRefReader)
import Util.Signal as Signal
import Type.Row (type (+))

type PROJECTION =
  Base.PROJECTION
    (READER_POSTGRES_STORE_CLIENT
        + READER_POSTGRES_EDGE_CLIENT
        + READER_SIGNAL_REF
        + AFF
        + EFFECT
        + ()
    )

type ProjectionM = Run PROJECTION

type Context =
  { postgresStoreClient :: Postgres.Client
  , postgresEdgeClient :: Postgres.Client
  , signalRef :: SignalRef
  }

runProjectionM :: ∀ @p a. IsProjection p _ _ _ _ _ _ _ => Context -> ProjectionM a -> Aff a
runProjectionM { postgresStoreClient, postgresEdgeClient, signalRef } =
  interpretProjectionReadFind
    ▷ interpretProjectionReadSyncProjectWithNoop
    ▷ interpretProjectionWriteCopyPersist
    ▷ interpretProjectionWriteOps
    ▷ evalProjectionWriteCopyState
    ▷ runPostgresStoreClientReader postgresStoreClient
    ▷ runPostgresEdgeClientReader postgresEdgeClient
    ▷ runSignalRefReader signalRef
    ▷ runBaseAff'

acquire :: Aff Context
acquire = do
  postgresStoreClient <- Postgres.createClient internalConfig.db.store
  postgresEdgeClient <- Postgres.createClient internalConfig.db.edge
  signalRef <- ʌ Signal.initSignal
  η { postgresStoreClient, postgresEdgeClient, signalRef }

complete :: Context -> Aff Ɩ
complete { postgresStoreClient, postgresEdgeClient } = do
  Postgres.closeClient postgresStoreClient
  Postgres.closeClient postgresEdgeClient
