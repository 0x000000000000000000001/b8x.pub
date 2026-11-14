module Core.Message.Command.Handle.Test.Integration.LoadBarrier
  ( LoadBarrier
  , newLoadBarrier
  , withLoadBarrier
  ) where

import Proem

import Core.Event.EventStore (EVENT_STORE, EventStore(..), appendEvents, loadEvents)
import Data.Array as Array
import Data.Functor.Variant (prj)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect.Aff (Aff, error, throwError)
import Effect.Aff.AVar as AVar
import Effect.AVar (AVar)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Run (AFF, Run, interpret, liftAff, send)
import Type.Row (type (+))
import Util.Lexicon.EventStore (eventStore')

type Round = { remaining :: Int, gate :: AVar Unit, startGate :: AVar Unit }
type Arrival = { gate :: AVar Unit, release :: Boolean }

newtype LoadBarrier = LoadBarrier (Ref (Array Round))

-- All participants finish the real database read before any may append.
-- Round sizes make the conflict stimulus independent of backend speed.
newLoadBarrier :: Array Int -> Aff LoadBarrier
newLoadBarrier counts = do
  rounds <- traverse newRound counts
  case Array.head rounds of
    Nothing -> η ι
    Just { startGate } -> AVar.put ι startGate
  LoadBarrier <$> ʌ (Ref.new rounds)
  where
  newRound :: Int -> Aff Round
  newRound remaining = do
    when (remaining <= 0) $ throwError $ error "LoadBarrier: positive round size required"
    gate <- AVar.empty
    startGate <- AVar.empty
    η { remaining, gate, startGate }

arrive :: Array Round -> { state :: Array Round, value :: Maybe Arrival }
arrive rounds = case Array.uncons rounds of
  Nothing -> { state: [], value: Nothing }
  Just { head: { remaining, gate, startGate }, tail } ->
    { state: remaining == 1 ? tail ↔ Array.cons { remaining: remaining - 1, gate, startGate } tail
    , value: Just { gate, release: remaining == 1 }
    }

awaitRound :: LoadBarrier -> Aff Unit
awaitRound (LoadBarrier state) = do
  arrival <- ʌ $ Ref.modify' arrive state
  case arrival of
    Nothing -> η ι
    Just { gate, release } -> release ? AVar.put ι gate ↔ AVar.read gate

awaitStart :: LoadBarrier -> Aff Unit
awaitStart (LoadBarrier state) = do
  rounds <- ʌ $ Ref.read state
  case Array.head rounds of
    Nothing -> η ι
    Just { startGate } -> AVar.read startGate

-- The next round must read the committed winner, not retry its old snapshot
-- while that winner still holds the database lock.
releaseAfterCommit :: LoadBarrier -> Aff Unit
releaseAfterCommit (LoadBarrier state) = do
  rounds <- ʌ $ Ref.read state
  case Array.head rounds of
    Nothing -> η ι
    Just { startGate } -> ø $ AVar.tryPut ι startGate

withLoadBarrier :: ∀ a fx. LoadBarrier -> Run (EVENT_STORE + AFF + fx) a -> Run (EVENT_STORE + AFF + fx) a
withLoadBarrier barrier = interpret \effect -> case prj eventStore' effect of
  Just command -> handle command
  Nothing -> send effect
  where
  handle :: ∀ b. EventStore b -> Run (EVENT_STORE + AFF + fx) b
  handle = case _ of
    LoadEvents filter next -> do
      liftAff $ awaitStart barrier
      events <- loadEvents filter
      liftAff $ awaitRound barrier
      η $ next events
    AppendEvents trace events lockInfo next -> do
      result <- appendEvents trace events lockInfo
      case result of
        Nothing -> η ι
        Just _ -> liftAff $ releaseAfterCommit barrier
      η $ next result
