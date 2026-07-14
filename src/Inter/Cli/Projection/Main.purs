module Inter.Cli.Projection.Main where

import Proem

import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig)
import Util.Env (Env(..))
import Control.Parallel (parTraverse_)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.String (trim)
import Effect (Effect)
import Effect.Aff (bracket, forkAff, delay, Milliseconds(..))
import Effect.Ref as Ref
import Foreign.Object as Object
import Inter.Cli.Projection.ProjectionM (acquire, complete)
import Inter.Cli.Projection.Registry (Projection(..), registry)
import Inter.Cli.Util.Aff (runCliAff)
import Inter.Cli.Util.Opt (execParser)
import Options.Applicative (Parser, argument, help, int, long, metavar, option, short, showDefault, str, value)
import Util.Log.Error (error)
import Util.Log.Info (info)
import Util.Ops.Ctl (updateService)
import Util.Signal (triggerSignal)

data Target = All | OnlyOne String

type Options =
  { target :: Target
  , readBatchSize :: Int
  , writeBatchSize :: Int
  , timeout :: Int
  }

description :: String
description = "Projection"

parser :: Parser Options
parser = ado
  name <- argument str
    ( metavar "NAME"
        <> help "Name of the projection to run (e.g. users). Give \"*\" to run all of them."
    )
  readBatchSize <- option int
    ( long "read-batch-size"
        <> metavar "SIZE"
        <> help "Number of events to fetch per batch"
        <> value 1000
        <> showDefault
    )
  writeBatchSize <- option int
    ( long "write-batch-size"
        <> metavar "SIZE"
        <> help "Number of events to process before updating checkpoint"
        <> value 100
        <> showDefault
    )
  timeout <- option int
    ( long "timeout"
        <> short 't'
        <> metavar "SECONDS"
        <> help "Timeout in seconds before auto-shutdown"
        <> showDefault
        <> value 300
    )
  in
    let
      name' = trim name
      target = if name' == "*" || name' == "all" then All else OnlyOne name'
    in
      { target, readBatchSize, writeBatchSize, timeout }

main :: Effect Ɩ
main = runCliAff do
  { target, readBatchSize, writeBatchSize, timeout } <- ʌ $ execParser description parser

  bracket acquire complete \ctx@{ signalRef } -> do
    timerStartedRef <- ʌ $ Ref.new false

    let
      onLockAcquired = do
        isStarted <- ʌ $ Ref.read timerStartedRef
        unless isStarted do
          ʌ $ Ref.write true timerStartedRef
          when (publicConfig.env == Prod) $ ø $ forkAff do
            info $ "I will stop automatically in " <> show timeout <> " seconds."
            delay $ Milliseconds (toNumber timeout * 1000.0)
            info $ "Timeout reached (" <> show timeout <> " seconds). Requesting zero-downtime update..."
            let
              serviceSuffix = case target of
                All -> "all"
                OnlyOne n -> n
            updateService (internalConfig.orch.services.proj.namePrefix <> serviceSuffix)
            info $ "Waiting up to 2 minutes for the orchestrator to send SIGTERM (or alike)..."
            delay $ Milliseconds $ 2.0 * 60_000.0
            info $ "No SIGTERM (or alike) received from the orchestrator. Self-interrupting..."
            ʌ $ triggerSignal signalRef

    case target of
      All -> do
        parTraverse_ (\(Projection def) -> def.run ctx readBatchSize writeBatchSize onLockAcquired) (Object.values registry)
      OnlyOne n -> case Object.lookup n registry of
        Just (Projection def) ->
          def.run ctx readBatchSize writeBatchSize onLockAcquired
        Nothing -> error $ "Unknown projection: " <> n
