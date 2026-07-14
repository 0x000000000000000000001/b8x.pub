module Core.Feat.Review.Message.Command.AddNewsTopic.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.AddNewsTopic.Exception.NewsTopicCannotBeAdded (NewsTopicCannotBeAdded(..))
import Core.Feat.Review.Message.Command.AddNewsTopic.Payload (Payload)
import Core.Feat.Review.Message.Command.AddNewsTopic.State (State)
import Core.Mod.NewsTopic.Id.Message.Field.AutoId (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (NewsTopicAdded { id }) -> η { id }
    _ -> throw NewsTopicCannotBeAdded
