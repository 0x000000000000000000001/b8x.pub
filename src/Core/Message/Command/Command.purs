module Core.Message.Command.Command where

import Proem

import Core.Event.Event (Event, LoadedEvent)
import Core.Event.EventStore (EVENT_STORE, appendEvents, loadEvents)
import Core.Event.Filter (Filter)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Exception (TooMuchConcurrency(..))
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Mod.Projection.Index (PROJECTION_READ)
import Core.Feat.Effect.Newsletter (NEWSLETTER)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Mail (MAIL)
import Core.Mod.Trace.Trace (READER_TRACE, askTrace)
import Core.Feat.Effect.Generate (GENERATE)
import Core.Feat.Effect.Sleep (SLEEP)
import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (foldl, last)
import Data.Either (Either(..))
import Data.Function (applyFlipped)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Run (Run, interpret, on, send)
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.Row.Row (class RecordKeysMatch)
import Util.Type.Type (class Reflect)

data PhantomChildConstraint (cmd :: Type) (a :: Type) = PhantomChildConstraintVoid Void

derive instance Functor (PhantomChildConstraint cmd)

type PHANTOM_CHILD_CONSTRAINT cmd fx = (phantomChildConstraint :: PhantomChildConstraint cmd | fx)

_phantomChildConstraint = π :: Π "phantomChildConstraint"

voidPhantomChildConstraint :: ∀ cmd fx a. Run (PHANTOM_CHILD_CONSTRAINT cmd + fx) a -> Run fx a
voidPhantomChildConstraint = interpret (on _phantomChildConstraint (\(PhantomChildConstraintVoid v) -> absurd v) send)

type Result a =
  { result :: a
  , newEvents :: Array LoadedEvent
  }

defaultResult :: ∀ a. a -> Result a
defaultResult result = { result, newEvents: [] }

data ConcurrencyPriority = Fast | Safe

derive instance Eq ConcurrencyPriority

class IsProtectedAgainstConcurrency (cmd :: Type) where
  priority :: ConcurrencyPriority
  maxRetries :: Int
  baseRetryDelayMs :: Int

class
  ( IsProtectedAgainstConcurrency cmd
  , Newtype cmd payload
  , ReadForeign cmd
  , WriteForeign cmd
  , Reflect cmd
  , Random cmd
  , RecordKeysMatch payload (Record fields)
  ) <=
  IsCommand
    cmd
    (state :: Type)
    (fields :: Row Type)
    payload
    a
  | cmd -> state
  , cmd -> fields
  , cmd -> payload
  , cmd -> a
  where
  description :: String

  handle :: ∀ fx. payload -> Run (PHANTOM_CHILD_CONSTRAINT cmd + EVENT_STORE + EXCEPT_LOGIC + PROJECTION_READ + UPLOAD + NEWSLETTER + RATE_LIMIT + CACHE + MAIL + READER_TRACE + GENERATE + SLEEP + READER_PUBLIC_CONFIG + fx) (Either TooMuchConcurrency (Result a))

defaultCheckLoadedEvents :: ∀ fx. Array LoadedEvent -> Run fx Ɩ
defaultCheckLoadedEvents = κηι

defaultMaxConcurrencyRetries :: Int
defaultMaxConcurrencyRetries = 50

defaultHandle
  :: ∀ @cmd state payload a fx
   . Newtype cmd payload
  => IsProtectedAgainstConcurrency cmd
  => Maybe (payload -> Filter) -- filter
  -> (∀ fx'. Array LoadedEvent -> Run (EVENT_STORE + EXCEPT_LOGIC + fx') Ɩ) -- checkLoadedEvents
  -> (payload -> state) -- initialState
  -> (state -> LoadedEvent -> state) -- play
  -> (∀ fx'. state -> payload -> Run (EXCEPT_LOGIC + UPLOAD + RATE_LIMIT + READER_TRACE + fx') (Array Event)) -- decide
  -> (∀ fx'. payload -> state -> Array Event -> Run (EXCEPT_LOGIC + UPLOAD + fx') a) -- toResult
  -> payload
  -> Run (EVENT_STORE + EXCEPT_LOGIC + PROJECTION_READ + UPLOAD + NEWSLETTER + RATE_LIMIT + CACHE + MAIL + READER_TRACE + GENERATE + READER_PUBLIC_CONFIG + fx) (Either TooMuchConcurrency (Result a))
defaultHandle
  filter
  checkLoadedEvents
  initialState
  play
  decide
  toResult
  payload = do
  let filter' = applyFlipped payload <$> filter

  loadedEvents <- filter' ?? loadEvents ⇔ η []

  checkLoadedEvents loadedEvents

  let
    state = foldl play (initialState payload) loadedEvents
    maxSequenceNumber = last loadedEvents <#> _.sequenceNumber
    lockInfo =
      { filter: filter'
      , expectedMaxSequenceNumber: maxSequenceNumber
      , requiresStrictConcurrencyProtection: priority @cmd == Safe
      }

  newEvents <- decide state payload

  trace <- askTrace

  mAppendedEvents <- appendEvents trace newEvents lockInfo

  case mAppendedEvents of
    Just appendedEvents -> do
      result <- toResult payload state newEvents
      η $ Right { result, newEvents: appendedEvents }
    Nothing ->
      η $ Left TooMuchConcurrency