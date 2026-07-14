module Core.Mod.Author.Exception.Index where

import Core.Mod.Author.Exception.AuthorAlreadyReferenced (AuthorAlreadyReferencedRow)
import Core.Mod.Author.Exception.AuthorNotReferenced (AuthorNotReferencedRow)
import Core.Mod.Author.Projection.Exception.Index (AuthorProjectionExceptionRow)
import Type.Row (type (+))

type AuthorExceptionRow r =
  AuthorAlreadyReferencedRow
    + AuthorNotReferencedRow
    + AuthorProjectionExceptionRow
    + r