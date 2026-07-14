module Core.Feat.Reference.Message.Command.ReferenceAuthor.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Exception.AuthorCannotBeReferenced (AuthorCannotBeReferenced(..))
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.State (State)
import Core.Mod.Author.Id.Message.Field.AutoId (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (AuthorReferenced { id }) -> η { id }
    _ -> throw AuthorCannotBeReferenced
