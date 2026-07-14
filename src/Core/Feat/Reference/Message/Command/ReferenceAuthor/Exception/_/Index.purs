module Core.Feat.Reference.Message.Command.ReferenceAuthor.Exception.Index where

import Core.Feat.Reference.Message.Command.ReferenceAuthor.Exception.AuthorCannotBeReferenced (AuthorCannotBeReferencedRow)
import Type.Row (type (+))

type ReferenceAuthorExceptionRow r =
  AuthorCannotBeReferencedRow
    + r
