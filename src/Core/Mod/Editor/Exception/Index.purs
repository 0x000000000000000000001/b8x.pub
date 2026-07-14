module Core.Mod.Editor.Exception.Index where

import Core.Mod.Editor.Exception.EditorNotReferenced (EditorNotReferencedRow)
import Type.Row (type (+))

type EditorExceptionRow r =
  EditorNotReferencedRow
    + r