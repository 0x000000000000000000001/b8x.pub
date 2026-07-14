module Util.Type.Proxy
  (π
  , Π
  ) where

import Type.Proxy (Proxy(..))

type Π :: ∀ k. k -> Type
type Π = Proxy

π :: ∀ @a. Π a
π = Proxy
