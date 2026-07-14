module Core.Feat.Process.Dispatch
  ( class DispatchEvents
  , dispatchEvents
  , dispatchEvents'
  , class DispatchEventsFromRowList
  , dispatchEventsFromRowList
  ) where

import Proem

import Core.Event.Event (LoadedEvent, WeakHeadEvent)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Process.Index (ProcessRow)
import Core.Feat.Process.Process (class IsProcess, async, handleEvent)
import Core.Feat.Effect.Generate (GENERATE)
import Core.Message.Queue (QUEUE, queueEvent)
import Yoga.JSON (readImpl, writeImpl)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Foldable (for_)
import Prim.RowList (class RowToList, Cons, Nil, RowList)
import Run (Run)
import Util.Type.Type (reflectName)
import Type.Row (type (+))
import Core.Mod.Trace.Trace (READER_TRACE, readerTrace')
import Core.Mod.Trace.Cause (CauseNode(..))
import Run.Reader (localAt)
import Data.Maybe (Maybe(..))

dispatchEvents :: ∀ fx. Array LoadedEvent -> Run (QUEUE + EXCEPT_LOGIC + READER_TRACE + GENERATE + fx) Ɩ
dispatchEvents = dispatchEvents' @ProcessRow

class DispatchEvents (processes :: Row Type) where
  dispatchEvents' :: ∀ fx. Array LoadedEvent -> Run (QUEUE + EXCEPT_LOGIC + READER_TRACE + GENERATE + fx) Ɩ

instance
  ( RowToList processes processesRowList
  , DispatchEventsFromRowList processesRowList
  ) =>
  DispatchEvents processes where
  dispatchEvents' = dispatchEventsFromRowList @processesRowList

class DispatchEventsFromRowList (processesRowList :: RowList Type) where
  dispatchEventsFromRowList :: ∀ fx. Array LoadedEvent -> Run (QUEUE + EXCEPT_LOGIC + READER_TRACE + GENERATE + fx) Ɩ

instance
  ( IsProcess process event payload
  , DispatchEventsFromRowList processesTail
  ) =>
  DispatchEventsFromRowList (Cons processName process processesTail) where
  dispatchEventsFromRowList events = do
    for_ events \loadedEvent -> do
      case runExcept (readImpl @WeakHeadEvent (writeImpl loadedEvent.event)) of
        Left _ -> ηι -- Obsolete. We cannot do anything with it. Our migrations must be done when the queues are empty.
        Right { type: type_, payload: payload' } -> when (type_ == reflectName @event) do
          case runExcept (readImpl payload') of
            Left _ -> ηι -- Ditto.
            Right payload -> do
              let trace = loadedEvent.meta.trace
              let
                processCause = Event
                  { name: reflectName @event
                  , id: loadedEvent.id
                  , run: trace.run
                  , append: trace.append
                  , cause: trace.cause
                  }

              localAt readerTrace' (\_ -> { run: trace.run, append: trace.append, cause: Just processCause, overriddenAt: Nothing }) do
                async @process
                  ? (queueEvent { event: loadedEvent, process: reflectName @process })
                  ↔ (handleEvent @process payload)

    dispatchEventsFromRowList @processesTail events

instance DispatchEventsFromRowList Nil where
  dispatchEventsFromRowList _ = ηι
