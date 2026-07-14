module Inter.Cli.Worker.WorkerM where

import Proem

import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig, READER_PUBLIC_CONFIG, runPublicConfigReader)
import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC, LogicException, runLogicExcept)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Generate (GENERATE, interpretGenerate)
import Core.Feat.Effect.Sleep (SLEEP, interpretSleep)
import Core.Feat.Effect.Mail (MAIL)
import Core.Feat.Effect.Newsletter (NEWSLETTER, interpretNewsletterWithMock)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Queue (QUEUE)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (evalProjectionWriteCopyState)
import Core.Mod.Infra.Projection.Index (PROJECTION)
import Core.Mod.Infra.Projection.Postgres.Finder.Index (interpretProjectionReadFind)
import Core.Mod.Infra.Projection.Postgres.Index (interpretProjectionReadSyncProject, interpretProjectionReadSyncProjectWithNoop, interpretProjectionWriteCopyPersist, interpretProjectionWriteOps)
import Core.Mod.Trace.Trace (READER_TRACE, Trace, runTraceReader)
import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Infra.Cache.Fs.Cache (interpretCache)
import Infra.Client.Aws.S3.S3 (READER_S3_CLIENT, interpretUpload, runS3ClientReader)
import Infra.Client.Aws.S3.S3 as S3
import Infra.Client.Aws.Ses.Ses (READER_SES_CLIENT, runSesClientReader)
import Infra.Client.Aws.Ses.Ses as Ses
import Infra.Client.Postgres.Postgres (READER_POSTGRES_STORE_CLIENT, READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_LOCK_CLIENT, runPostgresStoreClientReader, runPostgresEdgeClientReader, runPostgresStoreLockClientReader)
import Infra.Client.Postgres.Postgres as Postgres
import Infra.Client.RabbitMq.RabbitMq (READER_RABBIT_MQ_CLIENT, runRabbitMqClientReader)
import Infra.Client.RabbitMq.RabbitMq as RabbitMq
import Infra.Client.Sendy (READER_SENDY_CONFIG, runSendyConfigReader)
import Infra.Client.Mailchimp.Mailchimp (READER_MAILCHIMP_CONFIG, runMailchimpConfigReader)
import Infra.EventStore.Postgres.EventStore (interpretEventStore)
import Infra.Mail.Mock.Mail (interpretMailWithMock)
import Infra.Mail.Ses.Mail (interpretMail)
import Infra.Newsletter.Sendy (interpretNewsletter)
import Infra.Queue.RabbitMq.Queue (interpretQueue)
import Infra.RateLimit.Postgres.RateLimit (interpretRateLimit)
import Run (AFF, EFFECT, Run, runBaseAff')
import Type.Row (type (+))
import Util.Env (Env(..))
import Util.Signal (READER_SIGNAL_REF, SignalRef, initSignal, runSignalRefReader)

type WORKER =
  EVENT_STORE
    + QUEUE
    + GENERATE
    + SLEEP
    + UPLOAD
    + NEWSLETTER
    + RATE_LIMIT
    + CACHE
    + MAIL
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
    + READER_SIGNAL_REF
    + READER_TRACE
    + EXCEPT_LOGIC
    
    + AFF
    + EFFECT
    + ()

type WorkerM = Run WORKER

type Context =
  { postgresStoreClient :: Postgres.Client
  , postgresEdgeClient :: Postgres.Client
  , postgresStoreLockClient :: Postgres.Client
  , rabbitMqClient :: RabbitMq.Client
  , s3Client :: S3.Client
  , sesClient :: Ses.Client
  , signalRef :: SignalRef
  , busyRef :: Ref Int
  }

runWorkerM :: ∀ a. Context -> Trace -> WorkerM a -> Aff (Either LogicException a)
runWorkerM { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient, s3Client, sesClient, signalRef } traceContext ma =
  ma
    # interpretEventStore
    # interpretQueue
    # interpretProjectionReadFind
    #
      ( case publicConfig.env of
          Dev -> interpretProjectionReadSyncProject
          Prod -> interpretProjectionReadSyncProjectWithNoop
      )
    # interpretProjectionWriteCopyPersist
    # interpretProjectionWriteOps
    # interpretUpload
    #
      ( case publicConfig.env of
          Dev -> interpretNewsletterWithMock
          Prod -> interpretNewsletter
      )
    # interpretCache
    #
      ( case publicConfig.env of
          Dev -> interpretMailWithMock
          Prod -> interpretMail
      )
    # evalProjectionWriteCopyState
    # interpretRateLimit
    # runPostgresStoreClientReader postgresStoreClient
    # runPostgresEdgeClientReader postgresEdgeClient
    # runPostgresStoreLockClientReader postgresStoreLockClient
    # runRabbitMqClientReader rabbitMqClient
    # runS3ClientReader s3Client
    # runSesClientReader sesClient
    # runSendyConfigReader (Just internalConfig.sendy)
    # runMailchimpConfigReader (Just internalConfig.mailchimp)
    # runPublicConfigReader publicConfig
    # interpretGenerate
    # interpretSleep
    # runSignalRefReader signalRef
    # runTraceReader traceContext
    # runLogicExcept
    # runBaseAff'

acquire :: Aff Context
acquire = do
  postgresStoreClient <- Postgres.createClient internalConfig.db.store
  postgresEdgeClient <- Postgres.createClient internalConfig.db.edge
  postgresStoreLockClient <- Postgres.createClient internalConfig.db.storeLock
  rabbitMqClient <- RabbitMq.createLazyClient internalConfig.mq
  s3Client <- S3.createLazyClient internalConfig.aws.s3
  sesClient <- Ses.createLazyClient internalConfig.mail

  signalRef <- initSignal

  busyRef <- ʌ $ Ref.new 0

  η { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient, s3Client, sesClient, signalRef, busyRef }

complete :: Context -> Aff Ɩ
complete { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient } = do
  Postgres.closeClient postgresStoreClient
  Postgres.closeClient postgresEdgeClient
  Postgres.closeClient postgresStoreLockClient
  RabbitMq.closeClient rabbitMqClient
