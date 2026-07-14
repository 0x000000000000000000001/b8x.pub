module Util.Semaphor
  (Sem
  , lock
  , lockAcq
  , lockRel
  , parTraverseBounded
  , sem
  , semAcq
  , semRel
  )
  where

import Proem

import Concurrent.BoundedQueue (BoundedQueue)
import Concurrent.BoundedQueue as BQ
import Control.Parallel (parTraverse)
import Data.Array ((..))
import Data.Traversable (class Traversable, traverse_)
import Effect.Aff (Aff, bracket)
import Effect.Aff.Class (class MonadAff)

type Sem = BoundedQueue Ɩ

sem :: ∀ m. MonadAff m => Int -> m Sem
sem n = do
  s <- ʌ' $ BQ.new n
  traverse_ (κ $ ʌ' $ BQ.write s ι) (1 .. n)
  η s

semAcq :: ∀ m. MonadAff m => Sem -> m Ɩ
semAcq s = ʌ' $ BQ.read s

semRel :: ∀ m. MonadAff m => Sem -> m Ɩ
semRel q = ʌ' $ BQ.write q ι

lock :: ∀ m. MonadAff m => m Sem
lock = sem 1

lockAcq :: ∀ m. MonadAff m => Sem -> m Ɩ
lockAcq s = semAcq s

lockRel :: ∀ m. MonadAff m => Sem -> m Ɩ
lockRel s = semRel s

parTraverseBounded
  :: ∀ m t a b. MonadAff m => Traversable t
  => Int          -- maxInFlight
  -> (a -> Aff b) -- action
  -> t a          -- inputs
  -> m (t b)
parTraverseBounded maxInFlight k xs = do
  s <- sem maxInFlight
  ʌ' $ parTraverse
    (\x ->
      bracket
        (semAcq s)
        (κ $ semRel s)
        (κ $ k x)
    )
    xs