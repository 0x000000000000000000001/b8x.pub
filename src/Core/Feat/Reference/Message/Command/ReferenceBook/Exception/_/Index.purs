module Core.Feat.Reference.Message.Command.ReferenceBook.Exception.Index where

import Core.Feat.Reference.Message.Command.ReferenceBook.Exception.BookCannotBeReferenced (BookCannotBeReferencedRow)
import Type.Row (type (+))

type ReferenceBookExceptionRow r =
  BookCannotBeReferencedRow
    + r
