module Core.Message.Command.Compose where

import Proem

import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Command (class IsCommand, Result)
import Core.Message.Command.Command as Command
import Core.Message.Command.Handle.Exception (TooMuchConcurrency)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Feat.Effect.Newsletter (NEWSLETTER)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Mail (MAIL)
import Core.Mod.Projection.Index (PROJECTION_READ)
import Core.Mod.Trace.Cause (CauseNode(..))
import Core.Mod.Trace.Trace (READER_TRACE, askTrace, readerTrace')
import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Run (Run)
import Core.Feat.Effect.Generate (GENERATE)
import Core.Feat.Effect.Sleep (SLEEP)
import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Run.Reader (localAt)
import Type.Row (type (+))
import Util.Type.Type (class Reflect, reflectName)

-- | A macro-command can execute a (sub-)command synchronously while updating the causal tracing tree
-- | so that the sub-command appears as caused by the current executing command.
child
  :: ∀ @cmd state fields payload a fx
   . IsCommand cmd state fields payload a
  => Reflect cmd
  => payload
  -> Run
       (EVENT_STORE + EXCEPT_LOGIC + PROJECTION_READ + UPLOAD + NEWSLETTER + RATE_LIMIT + CACHE + MAIL + READER_TRACE + GENERATE + SLEEP + READER_PUBLIC_CONFIG  + fx)
       (Either TooMuchConcurrency (Result a))
child payload = do
  trace <- askTrace

  -- Create the new cause node for the sub-command
  -- Its parent ("cause") is the current trace.cause (the Super-Command)
  let
    subCommandCause = Command
      { name: reflectName @cmd
      , run: trace.run
      , subject: Nothing
      , cause: trace.cause
      }

  -- Temporarily override the trace environment for the sub-command execution
  localAt
    readerTrace'
    (_ { cause = Just subCommandCause })
    (Command.voidPhantomChildConstraint (Command.handle @cmd payload))
