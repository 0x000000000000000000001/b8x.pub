module Core.Feat.Reference.Message.Command.CorrectAuthor.Result where

import Proem

import Core.Event.Event (Event)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Payload (Payload)
import Core.Feat.Reference.Message.Command.CorrectAuthor.State (State)
import Core.Mod.Author.Id.Message.Field.AutoId (Id)
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult { id } _ _ = η { id }
