module Core.Feat.Reference.Message.Command.ReferenceEditor.Exception.Index where

import Core.Feat.Reference.Message.Command.ReferenceEditor.Exception.EditorCannotBeReferenced (EditorCannotBeReferencedRow)
import Type.Row (type (+))

type ReferenceEditorExceptionRow r =
  EditorCannotBeReferencedRow
    + r
