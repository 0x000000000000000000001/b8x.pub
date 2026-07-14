module Core.Mod.Book.Exception.Index where

import Core.Mod.Book.Exception.BookAlreadyReferenced (BookAlreadyReferencedRow)
import Core.Mod.Book.Exception.BookNotReferenced (BookNotReferencedRow)
import Core.Mod.Book.Projection.Exception.Index (BookProjectionExceptionRow)
import Type.Row (type (+))

type BookExceptionRow r =
  BookAlreadyReferencedRow
    + BookNotReferencedRow
    + BookProjectionExceptionRow
    + r