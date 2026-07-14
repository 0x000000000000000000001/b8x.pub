module Core.Feat.Reference.Message.Command.DereferenceEditor.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Payload (Payload)
import Core.Feat.Reference.Message.Command.DereferenceEditor.State (State)
import Core.Mod.Editor.Exception.EditorNotReferenced (EditorNotReferenced(..))
import Core.Mod.Editor.State as Editor
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide Editor.NotReferencedYet { editor } = throw $ EditorNotReferenced editor
decide Editor.Dereferenced { editor } = throw $ EditorNotReferenced editor
decide (Editor.Referenced _) { editor } = η [ EditorDereferenced { editor } ]
