module Inter.Cli.Projection.Registry where

import Proem

import Core.Mod.Projection.Index (ProjectionRow)
import Core.Mod.Projection.Projection (class IsProjection)
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Infra.Projection.Projector (project')
import Inter.Cli.Projection.ProjectionM (Context, PROJECTION, runProjectionM)
import Data.Symbol (class IsSymbol)
import Util.Type.Limit (Limit(..))
import Effect.Aff (Aff)
import Foreign.Object (Object)
import Foreign.Object as Object
import Prim.Row as Row
import Prim.RowList (Cons)
import Prim.Symbol (class Append)
import Run.State (State)
import Util.Type.Row.Registry (class RegistryBuilder, buildRegistry, buildRegistryFromRowList)

newtype Projection = Projection
  { name :: String
  , run :: Context -> Int -> Int -> Aff Ɩ -> Aff Ɩ
  }

data Projections

registry :: Object Projection
registry = buildRegistry @Projections @ProjectionRow

instance
  (IsSymbol projName
  , IsProjection proj projName opsEffSym opsEff _1 _2 _3 _4
  , Append projName "ProjectionWriteCopyState" copyOnWriteStateEffSym
  , Append projName "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  , IsSymbol opsEffSym
  , IsSymbol copyOnWriteStateEffSym
  , IsSymbol copyOnWritePersistEffSym
  , Row.Union opsEff fxOps PROJECTION
  , Row.Cons copyOnWriteStateEffSym (State CopyOnWrite) fxState PROJECTION
  , Row.Cons copyOnWritePersistEffSym ProjectionPersist fxPersist PROJECTION
  , RegistryBuilder Projections tail Projection
  ) =>
  RegistryBuilder Projections (Cons projName proj tail) Projection where
  buildRegistryFromRowList =
    let
      tailRegistry = buildRegistryFromRowList @Projections @tail

      name = ᴠ @projName
      run ctx readBatchSize writeBatchSize onLockAcquired = runProjectionM @proj ctx $ project' @proj (Finite readBatchSize) (Finite writeBatchSize) (ʌ' onLockAcquired)

      proj = Projection { name, run }
    in
      Object.insert name proj tailRegistry
