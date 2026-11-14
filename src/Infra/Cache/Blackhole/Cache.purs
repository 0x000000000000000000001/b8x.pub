module Infra.Cache.Blackhole.Cache (interpretCacheWithNoop) where

import Proem

import Core.Feat.Effect.Cache (CACHE, Cache(..), cache')
import Data.Maybe (Maybe(..))
import Run (Run, interpret, on, send)
import Type.Row (type (+))

-- | Always miss on reads and discard writes.
interpretCacheWithNoop :: ∀ fx a. Run (CACHE + fx) a -> Run fx a
interpretCacheWithNoop = interpret (on cache' handle send)
  where
  handle :: ∀ fx' a'. Cache a' -> Run fx' a'
  handle (Get _ next) = η $ next Nothing
  handle (Set _ _ _ next) = η $ next ι
