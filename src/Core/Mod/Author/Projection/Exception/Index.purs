module Core.Mod.Author.Projection.Exception.Index where

import Core.Mod.Author.Projection.Exception.InvalidAuthorFilter (InvalidAuthorFilterRow)
import Type.Row (type (+))

type AuthorProjectionExceptionRow r =
  InvalidAuthorFilterRow
    + r