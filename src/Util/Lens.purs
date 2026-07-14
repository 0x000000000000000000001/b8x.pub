module Util.Lens
  (_mapped
  ) where

import Proem

-- | Lens notation for map. Same name than in Haskell.
-- | This can get access into functor.
_mapped :: ∀ f a b. Functor f => (a -> b) -> f a -> f b
_mapped = map
