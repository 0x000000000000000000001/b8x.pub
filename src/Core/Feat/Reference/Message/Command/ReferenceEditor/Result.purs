module Core.Feat.Reference.Message.Command.ReferenceEditor.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Exception.EditorCannotBeReferenced (EditorCannotBeReferenced(..))
import Core.Feat.Reference.Message.Command.ReferenceEditor.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceEditor.State (State)
import Core.Mod.Editor.Id.Message.Field.AutoId (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (EditorReferenced { id }) -> η { id }
    _ -> throw EditorCannotBeReferenced
