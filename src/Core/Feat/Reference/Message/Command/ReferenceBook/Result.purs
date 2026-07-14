module Core.Feat.Reference.Message.Command.ReferenceBook.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.ReferenceBook.Exception.BookCannotBeReferenced (BookCannotBeReferenced(..))
import Core.Feat.Reference.Message.Command.ReferenceBook.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceBook.State (State)
import Core.Mod.Book.Id.Message.Field.AutoId (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (BookReferenced { id }) -> η { id }
    _ -> throw BookCannotBeReferenced
