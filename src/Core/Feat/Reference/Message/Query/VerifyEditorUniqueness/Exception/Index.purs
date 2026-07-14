module Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.Index where

import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.EditorAlreadyReferenced (EditorAlreadyReferencedRow)
import Type.Row (type (+))

type VerifyEditorUniquenessExceptionRow r =
  EditorAlreadyReferencedRow
    + r
