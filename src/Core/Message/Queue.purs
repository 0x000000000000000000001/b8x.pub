module Core.Message.Queue where

import Proem hiding (append)

import Core.Event.Event (LoadedEvent, WeakHeadLoadedEvent)
import Core.Message.Command.Command (class IsCommand)
import Core.Message.Command.Index (class FindCommandLabel, Command(..), CommandRow)
import Core.Mod.Trace.Trace (READER_TRACE, Trace, askTrace)
import Data.Symbol (class IsSymbol)
import Data.Variant (inj)
import Prim.Row as Row
import Prim.RowList (class RowToList)
import Run (Run, lift, on, send)
import Run as Run
import Type.Row (type (+))
import Util.Lexicon.Queue (queue')
import Util.Type.Row.Row (recordKeysMatch)

type EventToProcess =
  { event :: LoadedEvent
  , process :: String
  }

type WeakHeadEventToProcess =
  { event :: WeakHeadLoadedEvent
  , process :: String
  }

check :: Q ConstraintPredicate
check = recordKeysMatch @EventToProcess @WeakHeadEventToProcess

data Queue a
  = QueueCommand Trace Command a
  | QueueEvent Trace EventToProcess a

derive instance Functor Queue

type QUEUE fx = (queue :: Queue | fx)

queueCommand_ :: ∀ fx. Command -> Run (QUEUE + READER_TRACE + fx) Ɩ
queueCommand_ command = do
  trace <- askTrace
  lift queue' (QueueCommand trace command ι)

queueCommand
  :: ∀ cmd label state fields payload a rowList fx
   . RowToList CommandRow rowList
  => FindCommandLabel cmd rowList label
  => IsSymbol label
  => Row.Cons label cmd _ CommandRow
  => IsCommand cmd state fields payload a
  => cmd
  -> Run (QUEUE + READER_TRACE + fx) Ɩ
queueCommand cmd = queueCommand_ $ Command $ inj (π :: Π label) cmd

queueEvent :: ∀ fx. EventToProcess -> Run (QUEUE + READER_TRACE + fx) Ɩ
queueEvent event = do
  trace <- askTrace
  lift queue' (QueueEvent trace event ι)

interpretQueueWithNoop
  :: ∀ fx a
   . Run (QUEUE + fx) a
  -> Run fx a
interpretQueueWithNoop = Run.interpret (on queue' handle send)
  where
  handle :: ∀ fx' a'. Queue a' -> Run fx' a'
  handle (QueueCommand _ _ next) = η $ next
  handle (QueueEvent _ _ next) = η $ next