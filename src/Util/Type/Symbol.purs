module Util.Type.Symbol
  (τ
  , ᴠ
  , ᴠ'
  , ᴠ''
  ) where

import Data.Symbol (class IsSymbol, reflectSymbol, reifySymbol)
import Prim.Row (class Cons)
import Util.Type.Proxy (Π, π)
import Type.Equality (class TypeEquals)

-- | Type-level → Value-level
ᴠ :: ∀ @sym. IsSymbol sym => String
ᴠ = reflectSymbol (π @sym)

-- | Same than ᴠ, but with a row constraint:
-- | The symbol must be a key of the row.
ᴠ' :: ∀ @sym @row value rest. IsSymbol sym => Cons sym value rest row => String
ᴠ' = ᴠ @sym

-- | Same than ᴠ, but with a record row constraint:
-- | The symbol must be a key of the record row.
ᴠ'' :: ∀ @sym @record row value rest. IsSymbol sym => TypeEquals record (Record row) => Cons sym value rest row => String
ᴠ'' = ᴠ @sym

-- | Value-level → Type-level
τ :: ∀ r. String -> (∀ @sym. IsSymbol sym => r) -> r
τ s f = reifySymbol s f'
  where
  f' :: ∀ sym'. IsSymbol sym' => Π sym' -> r
  f' _ = f @sym'