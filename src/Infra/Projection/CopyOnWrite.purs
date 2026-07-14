module Infra.Projection.CopyOnWrite where

import Proem

import Core.Mod.Projection.Pair (Key)
import Core.Mod.Projection.Projection (class IsProjection)
import Foreign (Foreign)
import Data.Map (Map)
import Data.Maybe (Maybe)
import Data.Symbol (class IsSymbol)
import Prim.Row as Row
import Prim.Symbol (class Append)
import Run (Run, lift)

-- State

type Value_ = Maybe Foreign

data Value
  = Remote Value_
  | Local Value_

type CopyOnWrite = Map Key Value

-- Persist

data ProjectionPersist a = Persist (Boolean -> a)

derive instance Functor ProjectionPersist

persist
  :: ∀ @p name copyOnWritePersistEffSym fx
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol copyOnWritePersistEffSym
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => Row.Cons copyOnWritePersistEffSym ProjectionPersist _ fx
  => Run fx Boolean
persist = lift (π :: Π copyOnWritePersistEffSym) $ Persist identity
