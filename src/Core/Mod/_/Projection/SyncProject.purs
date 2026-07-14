module Core.Mod.Projection.SyncProject where

import Proem

import Core.Mod.Projection.Projection (class IsProjection)
import Data.Symbol (class IsSymbol)
import Prim.Row as Row
import Run (Run, lift)

data SyncProject a = Sync a

derive instance Functor SyncProject

-- Project synchronously. Useful for tests and/or local development.
syncProject
  :: ∀ @p syncEffSym fx
   . IsProjection p _ _ _ syncEffSym _ _ _
  => IsSymbol syncEffSym
  => Row.Cons syncEffSym SyncProject _ fx
  => Run fx Ɩ
syncProject = lift (π :: Π syncEffSym) $ Sync ι
