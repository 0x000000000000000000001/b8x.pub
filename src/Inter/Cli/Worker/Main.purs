module Inter.Cli.Worker.Main where

import Util.Foreign.Native as Util.Foreign.Native
import Proem

import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig)
import Util.Env (Env(..))
import Control.Monad.Rec.Class (forever)
import Core.Event.Event (WeakHeadEvent)
import Core.Message.Command.Index (WeakHeadCommand)
import Core.Message.Queue (WeakHeadEventToProcess)
import Yoga.JSON (readImpl, unsafeStringify)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), bracket, delay, finally, forkAff, launchAff_)
import Effect.Ref as Ref
import Foreign.Object as Object
import Core.Mod.Trace.Trace (Trace)
import Core.Mod.Trace.Cause (CauseNode(..))
import Core.Mod.Id.Id as Id
import Infra.Cache.Fs.Cache (deleteExpiredCache_)
import Infra.Client.RabbitMq.RabbitMq as RabbitMq
import Inter.Cli.Util.Aff (runCliAff)
import Inter.Cli.Util.Opt (execParser)
import Inter.Cli.Worker.Registry (commandHandlerRegistry, processRegistry)
import Inter.Cli.Worker.WorkerM (Context, acquire, complete, runWorkerM)
import Options.Applicative (Parser, help, int, long, metavar, option, short, showDefault, value)
import Run (runBaseAff')
import Util.I18n (Language(..), translate)
import Util.Log.Error (error)
import Util.Log.Except (except)
import Util.Log.Info (info)
import Util.Log.Success (success)
import Util.Ops.Ctl (updateService)
import Util.Signal (considerSignal__, triggerSignal)
import Util.Type.String.String (upperCaseFirst)
import Util.Type.Type (reflectVariantKeyName)

type Options =
  { timeout :: Int
  }

parser :: Parser Options
parser = ado
  timeout <- option int
    ( long "timeout"
        <> short 't'
        <> metavar "SECONDS"
        <> help "Timeout in seconds before auto-shutdown"
        <> showDefault
        <> value 300
    )
  in { timeout: timeout }

description :: String
description = "Worker process"

main :: Effect Ɩ
main = runCliAff do
  opts <- ʌ $ execParser description parser

  bracket acquire complete \ctx@{ rabbitMqClient, signalRef, busyRef } -> do
    -- Timeout
    when (publicConfig.env == Prod) $ ø $ forkAff do
      info $ "Starting the worker... I will stop automatically in " <> show opts.timeout <> " seconds."
      delay $ Milliseconds (toNumber opts.timeout * 1000.0)
      info $ "Timeout reached (" <> show opts.timeout <> " seconds). Requesting zero-downtime update..."
      updateService internalConfig.orch.services.api.worker.name
      info $ "Waiting up to 2 minutes for the orchestrator to send SIGTERM (or alike)..."
      delay $ Milliseconds $ 2.0 * 60_000.0
      info $ "No SIGTERM (or alike) received from the orchestrator. Self-interrupting..."
      ʌ $ triggerSignal signalRef

    --- Cache GC
    ø $ forkAff do
      let
        gcIntervalSec = 3600.0 -- 1 hour
        gcIntervalMs = 1000.0 * gcIntervalSec
      info $ "Starting cache garbage collector loop (" <> show gcIntervalSec <> " seconds interval)..."
      forever do
        runBaseAff' deleteExpiredCache_
        delay $ Milliseconds gcIntervalMs

    -- Command and event queues
    let
      commandQueueName = rabbitMqClient.config.queue.command.logic
      eventQueueName = rabbitMqClient.config.queue.event.logic

    runId <- ʌ Id.generate
    let workerTrace = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }

    ø $ runWorkerM ctx workerTrace do
      RabbitMq.assertConsume commandQueueName \msg -> launchAff_ do
        info $ "Received command:\n" <>
          case Util.Foreign.Native.parseJSON msg of
            Right json -> unsafeStringify json
            Left _ -> msg

        handleCommand ctx msg

      RabbitMq.assertConsume eventQueueName \msg -> launchAff_ do
        info $ "Received event:\n" <>
          case Util.Foreign.Native.parseJSON msg of
            Right json -> unsafeStringify json
            Left _ -> msg

        handleEvent ctx msg

    info $ "Worker listening on " <> commandQueueName <> " and " <> eventQueueName <> " queues..."

    forever do
      delay $ Milliseconds 250.0

      busy <- ʌ $ Ref.read busyRef

      when (busy == 0) $ considerSignal__ Nothing signalRef ηι

handleCommand ∷ Context -> String -> Aff Ɩ
handleCommand ctx@{ busyRef } msg = do
  ʌ $ Ref.modify_ (_ + 1) busyRef
  finally (ʌ $ Ref.modify_ (_ - 1) busyRef) do
    case Util.Foreign.Native.parseJSON msg of
      Left err -> error $ "Failed to parse command JSON: " <> show err
      Right json -> do
        case runExcept (readImpl @{ payload :: WeakHeadCommand, trace :: Trace } json) of
          Left err -> error $ "Failed to decode command structure: " <> show err
          Right { payload: { type: type_, payload }, trace: incomingTrace } -> do
            runId <- ʌ Id.generate

            let
              trace =
                { run: runId
                , append: Nothing
                , cause:
                    Just
                      $ Command
                          { name: type_
                          , run: runId
                          , subject: Nothing
                          , cause: incomingTrace.cause
                          }
                , overriddenAt: Nothing
                }

            case Object.lookup type_ commandHandlerRegistry of
              Nothing -> error $ "Unknown command: " <> type_
              Just handler -> handle trace handler payload

  where
  handle trace handler payload = do
    result <- runWorkerM ctx trace (handler payload)
    case result of
      Left e -> except $ "[" <> (upperCaseFirst $ reflectVariantKeyName $ unwrap e) <> "] " <> (translate En e)
      Right res -> do
        success
          $ "Command handled successfully.\nMessage:\n"
          <>
            ( case Util.Foreign.Native.parseJSON msg of
                Right parsedJson -> unsafeStringify parsedJson
                Left _ -> msg
            )
          <> "\nResult:\n"
          <> (unsafeStringify res == "{}" || unsafeStringify res == "null" ? "{}" ↔ unsafeStringify res)

handleEvent ∷ Context → String -> Aff Ɩ
handleEvent ctx@{ busyRef } msg = do
  ʌ $ Ref.modify_ (_ + 1) busyRef
  finally (ʌ $ Ref.modify_ (_ - 1) busyRef) do
    case Util.Foreign.Native.parseJSON msg of
      Left err -> error $ "Failed to parse event JSON: " <> show err
      Right json -> do
        case runExcept (readImpl @{ payload :: WeakHeadEventToProcess, trace :: Trace } json) of
          Left err -> error $ "Failed to decode EventToProcess structure: " <> show err
          Right { payload: { event, process }, trace: incomingTrace } -> do
            case Object.lookup process processRegistry of
              Nothing -> error $ "Unknown process: " <> process
              Just handler -> case runExcept (readImpl @WeakHeadEvent event.event) of
                Left err -> error $ "Failed to decode Event structure: " <> show err
                Right { type: _, payload } -> do
                  runId <- ʌ Id.generate

                  let
                    trace =
                      { run: runId
                      , append: Nothing
                      , cause: incomingTrace.cause
                      , overriddenAt: Nothing
                      }

                  handle trace handler payload

  where
  handle trace handler json = do
    result <- runWorkerM ctx trace (handler json)
    case result of
      Left e -> except $ "[" <> (upperCaseFirst $ reflectVariantKeyName $ unwrap e) <> "] " <> (translate En e)
      Right _ -> do
        success
          $ "Process executed successfully.\nMessage:\n"
          <>
            ( case Util.Foreign.Native.parseJSON msg of
                Right parsedJson -> unsafeStringify parsedJson
                Left _ -> msg
            )

