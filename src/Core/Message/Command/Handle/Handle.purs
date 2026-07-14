module Core.Message.Command.Handle.Handle where

import Proem hiding (append)

import Core.Event.EventStore (EVENT_STORE)
import Core.Event.Filter (Filter)
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Command (class IsCommand, maxRetries, baseRetryDelayMs)
import Core.Message.Command.Command as Command
import Core.Message.Command.Handle.Exception (TooMuchConcurrency(..))
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Queue (QUEUE)
import Core.Feat.Effect.Newsletter (NEWSLETTER)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Mail (MAIL)
import Core.Mod.Trace.Trace (READER_TRACE)
import Core.Feat.Effect.Generate (GENERATE, randomInt)
import Core.Feat.Effect.Sleep (SLEEP, sleep)
import Core.Feat.Process.Dispatch as ProcessDispatch
import Core.Mod.Projection.Index (PROJECTION_READ)
import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Data.Either (Either(..))
import Data.Newtype (unwrap)
import Run (Run)
import Type.Row (type (+))

type Result a =
  { result :: a
  , tries :: Int
  , retries :: Int
  }

type OptimisticLockInfo =
  { filter :: Filter
  , maxSequenceNumber :: String
  }

data NoConcurrencyIsolationResult a
  = Passed (Result a)
  | Stopped

derive instance Functor NoConcurrencyIsolationResult

handleCommand'
  :: ∀ @cmd state fields payload fx a
   . IsCommand cmd state fields payload a
  => Boolean
  -> cmd
  -> Run
       ( EVENT_STORE
           + EXCEPT_LOGIC
           + QUEUE
           + PROJECTION_READ
           + UPLOAD
           + NEWSLETTER
           + RATE_LIMIT
           + CACHE
           + MAIL
           + GENERATE
           + SLEEP
           + READER_TRACE
           + READER_PUBLIC_CONFIG
           + fx
       )
       (Result a)
handleCommand' dispatchEvents cmd = go 0
  where
  go retry = do
    res <- Command.voidPhantomChildConstraint $ Command.handle @cmd $ unwrap cmd

    case res of
      Left TooMuchConcurrency ->
        retry == maxRetries @cmd
          ? (throw TooMuchConcurrency)
          ↔ do
              let baseDelay = baseRetryDelayMs @cmd
              jitter <- randomInt 0 baseDelay
              sleep (baseDelay + jitter)
              go (retry + 1)

      Right { result, newEvents } -> do
        when dispatchEvents $ ProcessDispatch.dispatchEvents newEvents

        η { result, tries: retry + 1, retries: retry }

handleCommand
  :: ∀ @cmd state fields payload fx a
   . IsCommand cmd state fields payload a
  => Boolean
  -> cmd
  -> Run
       ( EVENT_STORE
           + EXCEPT_LOGIC
           + QUEUE
           + PROJECTION_READ
           + UPLOAD
           + NEWSLETTER
           + RATE_LIMIT
           + CACHE
           + MAIL
           + GENERATE
           + SLEEP
           + READER_TRACE
           + READER_PUBLIC_CONFIG
           + fx
       )
       a
handleCommand dispatchEvents command = handleCommand' dispatchEvents command >>= (η ◁ _.result)

handleCommand_
  :: ∀ @cmd state fields payload fx a
   . IsCommand cmd state fields payload a
  => Boolean
  -> cmd
  -> Run
       ( EVENT_STORE
           + EXCEPT_LOGIC
           + QUEUE
           + PROJECTION_READ
           + UPLOAD
           + NEWSLETTER
           + RATE_LIMIT
           + CACHE
           + MAIL
           + GENERATE
           + SLEEP
           + READER_TRACE
           + READER_PUBLIC_CONFIG
           + fx
       )
       Ɩ
handleCommand_ dispatchEvents command = ø $ handleCommand' dispatchEvents command
