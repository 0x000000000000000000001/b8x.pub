module Infra.Projection.Postgres.Finder.Test.Integration.TestM where

import Proem hiding (append)
import Data.Maybe (Maybe(..))

import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC, runLogicExcept)
import Core.Message.Command.Handle.Upload (UPLOAD, interpretUploadWithMock)
import Core.Message.Queue (QUEUE, interpretQueueWithNoop)
import Core.Feat.Effect.Newsletter (NEWSLETTER, interpretNewsletterWithMock)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Mail (MAIL)
import Core.Feat.Effect.Generate (GENERATE, interpretGenerate)
import Core.Feat.Effect.Sleep (SLEEP, interpretSleep)
import Config.PublicConfig (READER_PUBLIC_CONFIG, publicConfig, runPublicConfigReader)
import Infra.Mail.Mock.Mail (interpretMailWithMock)
import Infra.Cache.Fs.Cache (interpretCache)
import Core.Mod.Id.Id as Id
import Infra.RateLimit.Postgres.RateLimit (interpretRateLimit)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (evalProjectionWriteCopyState)
import Core.Mod.Infra.Projection.Index (PROJECTION)
import Core.Mod.Infra.Projection.Postgres.Finder.Index (interpretProjectionReadFind)
import Core.Mod.Infra.Projection.Postgres.Index (interpretProjectionWriteCopyPersist, interpretProjectionWriteOps, interpretProjectionReadSyncProject)
import Core.Mod.Trace.Trace (READER_TRACE, runTraceReader)
import Data.Either (Either(..))
import Effect.Aff (Aff, error, throwError)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT, READER_POSTGRES_STORE_LOCK_CLIENT, runPostgresEdgeClientReader, runPostgresStoreClientReader, runPostgresStoreLockClientReader)
import Infra.Client.Postgres.Postgres as Postgres
import Infra.Client.RabbitMq.RabbitMq (READER_RABBIT_MQ_CLIENT, runRabbitMqClientReader)
import Infra.Client.RabbitMq.RabbitMq as RabbitMq
import Infra.EventStore.Postgres.EventStore (interpretEventStore)
import Run (AFF, EFFECT, Run, runBaseAff')
import Type.Row (type (+))
import Util.I18n (Language(..), translate)

type TEST =
  PROJECTION
    + EVENT_STORE
    + QUEUE
    + UPLOAD
    + NEWSLETTER
    + RATE_LIMIT
    + CACHE
    + MAIL
    + GENERATE
    + SLEEP
    + READER_PUBLIC_CONFIG
    + READER_POSTGRES_EDGE_CLIENT
    + READER_POSTGRES_STORE_CLIENT
    + READER_POSTGRES_STORE_LOCK_CLIENT
    + READER_RABBIT_MQ_CLIENT
    + READER_TRACE
    + EXCEPT_LOGIC
    + AFF
    + EFFECT
    + ()

type TestM = Run TEST

type Context =
  { postgresStoreClient :: Postgres.Client
  , postgresEdgeClient :: Postgres.Client
  , postgresStoreLockClient :: Postgres.Client
  , rabbitMqClient :: RabbitMq.Client
  }

runTestM :: ∀ a. Context -> TestM a -> Aff a
runTestM { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient } ma = do
  res <- ma
    # interpretProjectionReadFind
    # interpretProjectionReadSyncProject
    # interpretProjectionWriteCopyPersist
    # interpretProjectionWriteOps
    # evalProjectionWriteCopyState
    # interpretEventStore
    # interpretQueueWithNoop
    # interpretUploadWithMock
    # interpretNewsletterWithMock
    # interpretRateLimit
    # interpretCache
    # interpretMailWithMock
    # interpretGenerate
    # interpretSleep
    # runPublicConfigReader publicConfig
    # runPostgresEdgeClientReader postgresEdgeClient
    # runPostgresStoreClientReader postgresStoreClient
    # runPostgresStoreLockClientReader postgresStoreLockClient
    # runRabbitMqClientReader rabbitMqClient
    # runTraceReader { run: Id.unsafeGenerate ι, append: Nothing, cause: Nothing, overriddenAt: Nothing }
    # runLogicExcept
    # runBaseAff'

  case res of
    Left e -> throwError $ error $ translate En e
    Right a -> η a
