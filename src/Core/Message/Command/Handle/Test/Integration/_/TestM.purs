module Core.Message.Command.Handle.Test.Integration.TestM where

import Proem hiding (append)
import Data.Maybe (Maybe(..))
import Config.PublicConfig (READER_PUBLIC_CONFIG, publicConfig, runPublicConfigReader)

import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC, runLogicExcept)
import Core.Message.Command.Handle.Upload (UPLOAD, interpretUploadWithMock)
import Core.Feat.Effect.Newsletter (NEWSLETTER, interpretNewsletterWithMock)
import Core.Feat.Effect.Generate (GENERATE, interpretGenerate)
import Core.Feat.Effect.Sleep (SLEEP, interpretSleep)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Infra.RateLimit.Postgres.RateLimit (interpretRateLimit)
import Core.Mod.Trace.Trace (READER_TRACE, runTraceReader)
import Data.Either (Either(..))
import Core.Mod.Id.Id as Id
import Effect.Aff (Aff, error, throwError)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT, READER_POSTGRES_STORE_LOCK_CLIENT, runPostgresEdgeClientReader, runPostgresStoreClientReader, runPostgresStoreLockClientReader)
import Infra.Client.Postgres.Postgres as Postgres
import Infra.Client.RabbitMq.RabbitMq (READER_RABBIT_MQ_CLIENT, runRabbitMqClientReader)
import Infra.Client.RabbitMq.RabbitMq as RabbitMq
import Infra.EventStore.Postgres.EventStore (interpretEventStore)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (evalProjectionWriteCopyState)
import Core.Mod.Infra.Projection.Index (PROJECTION)
import Core.Mod.Infra.Projection.Postgres.Finder.Index (interpretProjectionReadFind)
import Core.Mod.Infra.Projection.Postgres.Index (interpretProjectionReadSyncProject, interpretProjectionWriteCopyPersist, interpretProjectionWriteOps)
import Run (AFF, EFFECT, Run, runBaseAff')
import Type.Row (type (+))
import Util.I18n (Language(..), translate)
import Core.Message.Queue (QUEUE, interpretQueueWithNoop)
import Core.Feat.Effect.Cache (CACHE)
import Infra.Cache.Fs.Cache (interpretCache)
import Core.Feat.Effect.Mail (MAIL)
import Infra.Mail.Mock.Mail (interpretMailWithMock)

type TEST =
  EVENT_STORE
    + PROJECTION
    + GENERATE
    + SLEEP
    + UPLOAD
    + NEWSLETTER
    + RATE_LIMIT
    + READER_POSTGRES_EDGE_CLIENT
    + READER_POSTGRES_STORE_CLIENT
    + READER_POSTGRES_STORE_LOCK_CLIENT
    + READER_RABBIT_MQ_CLIENT
    + READER_TRACE
    + READER_PUBLIC_CONFIG
    + EXCEPT_LOGIC
    + QUEUE
    + CACHE
    + MAIL
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
    # interpretEventStore
    # interpretProjectionReadFind
    # interpretProjectionReadSyncProject
    # interpretProjectionWriteCopyPersist
    # interpretProjectionWriteOps
    # evalProjectionWriteCopyState
    # interpretUploadWithMock
    # interpretNewsletterWithMock
    # interpretRateLimit
    # interpretGenerate
    # interpretSleep
    # interpretQueueWithNoop
    # interpretCache
    # interpretMailWithMock
    # runPostgresEdgeClientReader postgresEdgeClient
    # runPostgresStoreClientReader postgresStoreClient
    # runPostgresStoreLockClientReader postgresStoreLockClient
    # runRabbitMqClientReader rabbitMqClient
    # runPublicConfigReader publicConfig
    # runTraceReader { run: Id.unsafeGenerate ι, append: Nothing, cause: Nothing, overriddenAt: Nothing }
    # runLogicExcept
    # runBaseAff'

  case res of
    Left e -> throwError $ error $ translate En e
    Right a -> η a
