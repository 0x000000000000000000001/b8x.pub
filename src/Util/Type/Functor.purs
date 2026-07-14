module Util.Type.Functor
  (ø
  ) where

import Prelude

import Util.Unit (Ɩ)

ø :: ∀ f a. Functor f => f a -> f Ɩ
ø = void
