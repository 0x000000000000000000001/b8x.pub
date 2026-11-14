module Test.Main where

import Proem

import Control.Monad.Writer (execWriter)
import Core.Test as Core
import Data.DateTime.Instant (unInstant)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Number.Format (toStringWith, fixed)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (launchAff_, try)
import Effect.Console as Console
import Effect.Now (now)
import Infra.Test as Infra
import Inter.Cli.Util.KeepAlive (keepMainAlive)
import Node.Process (exit')
import Test.Spec.Reporter.Base (defaultSummary)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Reporter.Dot (dotReporter)
import Test.Spec.Runner.Node (runSpecAndGetResults)
import Test.Spec.Runner.Node.Config (defaultConfig)
import Test.Spec.Summary (successful)
import Util.Test as Util

main :: Effect Unit
main = do
  launchAff_ do
    start <- ʌ $ now

    let (Milliseconds msStart) = unInstant start

    res <- try $ runSpecAndGetResults (defaultConfig { timeout = Just (Milliseconds 300000.0) }) [ consoleReporter, dotReporter { width: 80 } ] do
      Core.spec
      Infra.spec
      Util.spec

    case res of
      Left err -> do
        ʌ $ Console.log $ "Aff crashed: " <> show err
        ʌ $ exit' 1
      Right res' -> do
        end <- ʌ $ now

        let
          (Milliseconds msEnd) = unInstant end
          durationSec = (msEnd - msStart) / 1000.0
          summaryText = execWriter (defaultSummary res')

        ʌ $ Console.log summaryText
        ʌ $ Console.log $ "⏱️  Tests execution completed in " <> toStringWith (fixed 2) durationSec <> "s"
        ʌ $ exit' $ successful res' ? 0 ↔ 1

  keepMainAlive
