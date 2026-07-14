module Core.Feat.Reference.Message.Command.Exception.Index where

import Core.Feat.Reference.Message.Command.ReferenceAuthor.Exception.Index (ReferenceAuthorExceptionRow)
import Core.Feat.Reference.Message.Command.ReferenceBook.Exception.Index (ReferenceBookExceptionRow)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Exception.Index (ReferenceEditorExceptionRow)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.Index (ReferenceMagazineIssueExceptionRow)
import Type.Row (type (+))

type ReferenceCommandExceptionRow r =
  ReferenceAuthorExceptionRow
    + ReferenceBookExceptionRow
    + ReferenceEditorExceptionRow
    + ReferenceMagazineIssueExceptionRow
    + r