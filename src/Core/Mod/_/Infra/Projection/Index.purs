module Core.Mod.Infra.Projection.Index where

import Core.Mod.Projection.Index (PROJECTION_READ, PROJECTION_WRITE_OPS)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (PROJECTION_WRITE_COPY)
import Type.Row (type (+))

type PROJECTION_WRITE fx =
  PROJECTION_WRITE_OPS
    + PROJECTION_WRITE_COPY
    + fx

type PROJECTION fx =
  PROJECTION_WRITE
    + PROJECTION_READ
    + fx
