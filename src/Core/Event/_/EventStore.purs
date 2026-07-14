module Core.Event.EventStore
  ( EVENT_STORE
  , EventStore(..)
  , OptimisticLockInfo
  , appendEvents
  , loadEvents
  ) where

import Proem hiding (append)

import Core.Event.Event (Event, LoadedEvent)
import Core.Event.Filter (Filter)
import Data.Maybe (Maybe)
import Run (Run, lift)
import Util.Lexicon.EventStore (eventStore')
import Type.Row (type (+))
import Core.Mod.Trace.Trace (Trace)

type OptimisticLockInfo =
  { filter :: Maybe Filter
  , expectedMaxSequenceNumber :: Maybe String
  , requiresStrictConcurrencyProtection :: Boolean
  }

data EventStore a
  = AppendEvents Trace (Array Event) OptimisticLockInfo (Maybe (Array LoadedEvent) -> a)
  | LoadEvents Filter (Array LoadedEvent -> a)

derive instance Functor EventStore

type EVENT_STORE fx = (eventStore :: EventStore | fx)

appendEvents :: ∀ fx. Trace -> Array Event -> OptimisticLockInfo -> Run (EVENT_STORE + fx) (Maybe (Array LoadedEvent))
appendEvents trace events optimisticLockInfo = lift eventStore' (AppendEvents trace events optimisticLockInfo identity)

loadEvents :: ∀ fx. Filter -> Run (EVENT_STORE + fx) (Array LoadedEvent)
loadEvents filter = lift eventStore' (LoadEvents filter identity)
