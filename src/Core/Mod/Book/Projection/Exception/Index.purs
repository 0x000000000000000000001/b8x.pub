module Core.Mod.Book.Projection.Exception.Index where

import Core.Mod.Book.Projection.Exception.InvalidBookFilter (InvalidBookFilterRow)
import Type.Row (type (+))

type BookProjectionExceptionRow r =
  InvalidBookFilterRow
    + r
