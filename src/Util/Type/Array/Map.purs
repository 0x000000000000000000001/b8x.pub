module Util.Type.Array.Map
  (arrayToIndexMap
  ) where

import Proem

import Data.Array (mapWithIndex)
import Data.Map (Map, fromFoldable)
import Data.Tuple (Tuple(..))

arrayToIndexMap :: ∀ a. Ord a => Array a -> Map a Int
arrayToIndexMap = fromFoldable ◁ mapWithIndex (flip Tuple)