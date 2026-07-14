module Inter.Cli.Logic.LogicM where

import Proem

import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig, READER_PUBLIC_CONFIG, runPublicConfigReader)
import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC, LogicException, runLogicExcept)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Feat.Effect.Generate (GENERATE, interpretGenerate)
import Core.Feat.Effect.Sleep (SLEEP, interpretSleep)
import Core.Message.Queue (QUEUE)
import Core.Feat.Effect.Newsletter (NEWSLETTER)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Infra.RateLimit.Postgres.RateLimit (interpretRateLimit)
import Core.Mod.Trace.Trace (READER_TRACE, Trace, runTraceReader)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Mail (MAIL)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (evalProjectionWriteCopyState)
import Core.Mod.Infra.Projection.Index (PROJECTION)
import Core.Mod.Infra.Projection.Postgres.Finder.Index (interpretProjectionReadFind)
import Core.Mod.Infra.Projection.Postgres.Index (interpretProjectionReadSyncProject, interpretProjectionReadSyncProjectWithNoop, interpretProjectionWriteCopyPersist, interpretProjectionWriteOps)
import Core.Mod.Id.Id as Id
import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Infra.Client.Aws.S3.S3 (READER_S3_CLIENT, interpretUpload, runS3ClientReader)
import Infra.Client.Aws.S3.S3 as S3
import Infra.Client.Aws.Ses.Ses (READER_SES_CLIENT, runSesClientReader)
import Infra.Client.Aws.Ses.Ses as Ses
import Infra.Client.Sendy (READER_SENDY_CONFIG, runSendyConfigReader)
import Infra.Client.Mailchimp.Mailchimp (READER_MAILCHIMP_CONFIG, runMailchimpConfigReader)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_STORE_CLIENT, READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_LOCK_CLIENT, runPostgresStoreClientReader, runPostgresEdgeClientReader, runPostgresStoreLockClientReader)
import Infra.Client.Postgres.Postgres as Postgres
import Infra.Client.RabbitMq.RabbitMq (READER_RABBIT_MQ_CLIENT, runRabbitMqClientReader)
import Infra.Client.RabbitMq.RabbitMq as RabbitMq
import Infra.Cache.Fs.Cache (interpretCache)
import Infra.EventStore.Postgres.EventStore (interpretEventStore)
import Infra.Mail.Mock.Mail (interpretMailWithMock)
import Infra.Mail.Ses.Mail (interpretMail)
import Infra.Newsletter.Sendy (interpretNewsletter)
import Infra.Queue.RabbitMq.Queue (interpretQueue)
import Run (AFF, EFFECT, Run, runBaseAff')
import Type.Row (type (+))
import Util.Env (Env(..))

type LOGIC =
  EVENT_STORE
    + QUEUE
    + GENERATE
    + SLEEP
    + UPLOAD
    + NEWSLETTER
    + CACHE
    + MAIL
    + RATE_LIMIT
    + PROJECTION
    + READER_POSTGRES_STORE_CLIENT
    + READER_POSTGRES_EDGE_CLIENT
    + READER_POSTGRES_STORE_LOCK_CLIENT
    + READER_RABBIT_MQ_CLIENT
    + READER_S3_CLIENT
    + READER_SES_CLIENT
    + READER_SENDY_CONFIG
    + READER_MAILCHIMP_CONFIG
    + READER_PUBLIC_CONFIG
    + READER_TRACE
    + EXCEPT_LOGIC
    
    + AFF
    + EFFECT
    + ()

type ASYNC_LOGIC =
  QUEUE
    + GENERATE
    + SLEEP
    + READER_RABBIT_MQ_CLIENT
    + READER_TRACE
    + EXCEPT_LOGIC
    + AFF
    + EFFECT
    + ()

type LogicM = Run LOGIC
type AsyncLogicM = Run ASYNC_LOGIC

type Context =
  { postgresStoreClient :: Postgres.Client
  , postgresEdgeClient :: Postgres.Client
  , postgresStoreLockClient :: Postgres.Client
  , rabbitMqClient :: RabbitMq.Client
  , s3Client :: S3.Client
  , sesClient :: Ses.Client
  }

type AsyncContext =
  { rabbitMqClient :: RabbitMq.Client
  }

runLogicM :: ∀ a. Context -> Trace -> LogicM a -> Aff (Either LogicException a)
runLogicM { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient, s3Client, sesClient } traceContext ma =
  ma
    # interpretEventStore
    ▷ interpretQueue

    ▷ interpretUpload
    ▷ interpretProjectionReadFind
    ▷
      ( case publicConfig.env of
          Dev -> interpretProjectionReadSyncProject
          Prod -> interpretProjectionReadSyncProjectWithNoop
      )
    ▷ interpretProjectionWriteCopyPersist
    ▷ interpretProjectionWriteOps
    ▷ interpretNewsletter
    ▷
      ( case publicConfig.env of
          Dev -> interpretMailWithMock
          Prod -> interpretMail
      )
    ▷ evalProjectionWriteCopyState
    ▷ interpretCache
    ▷ interpretRateLimit
    ▷ runPostgresStoreClientReader postgresStoreClient
    ▷ runPostgresEdgeClientReader postgresEdgeClient
    ▷ runPostgresStoreLockClientReader postgresStoreLockClient
    ▷ runRabbitMqClientReader rabbitMqClient
    ▷ runS3ClientReader s3Client
    ▷ runSesClientReader sesClient
    ▷ runSendyConfigReader (Just internalConfig.sendy)
    ▷ runMailchimpConfigReader (Just internalConfig.mailchimp)
    ▷ runPublicConfigReader publicConfig
    ▷ interpretGenerate
    ▷ interpretSleep
    ▷ runTraceReader traceContext
    ▷ runLogicExcept
    ▷ runBaseAff'

runAsyncLogicM :: ∀ a. AsyncContext -> AsyncLogicM a -> Aff (Either LogicException a)
runAsyncLogicM { rabbitMqClient } ma =
  ma
    # interpretQueue
    # runRabbitMqClientReader rabbitMqClient
    # interpretGenerate
    # interpretSleep
    # runTraceReader { run: Id.unsafeGenerate ι, append: Nothing, cause: Nothing, overriddenAt: Nothing }
    # runLogicExcept
    # runBaseAff'

acquireSync :: Aff Context
acquireSync = do
  postgresStoreClient <- Postgres.createClient internalConfig.db.store
  postgresEdgeClient <- Postgres.createClient internalConfig.db.edge
  postgresStoreLockClient <- Postgres.createClient internalConfig.db.storeLock
  rabbitMqClient <- RabbitMq.createLazyClient internalConfig.mq
  s3Client <- S3.createLazyClient internalConfig.aws.s3
  sesClient <- Ses.createLazyClient internalConfig.mail

  η { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient, s3Client, sesClient }

completeSync :: Context -> Aff Ɩ
completeSync { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient } = do
  Postgres.closeClient postgresStoreClient
  Postgres.closeClient postgresEdgeClient
  Postgres.closeClient postgresStoreLockClient
  RabbitMq.closeClient rabbitMqClient

acquireAsync :: Aff AsyncContext
acquireAsync = do
  rabbitMqClient <- RabbitMq.createClient internalConfig.mq

  η { rabbitMqClient }

completeAsync :: AsyncContext -> Aff Ɩ
completeAsync { rabbitMqClient } = RabbitMq.closeClient rabbitMqClient
