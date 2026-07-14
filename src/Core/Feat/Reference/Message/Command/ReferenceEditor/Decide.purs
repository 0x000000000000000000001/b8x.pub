module Core.Feat.Reference.Message.Command.ReferenceEditor.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceEditor.State (State)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.EditorAlreadyReferenced (EditorAlreadyReferenced(..))
import Core.Mod.Editor.State as Editor
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide Editor.NotReferencedYet { id, name, legacyBookIds } = η [ EditorReferenced { id, name, legacyBookIds } ]
decide Editor.Dereferenced { id, name, legacyBookIds } = η [ EditorReferenced { id, name, legacyBookIds } ]
decide (Editor.Referenced _) _ = throw EditorAlreadyReferenced
