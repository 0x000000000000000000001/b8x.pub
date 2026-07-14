module Core.Feat.Review.Message.Command.AddNewsTopic.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.AddNewsTopic.Payload (Payload)
import Core.Feat.Review.Message.Command.AddNewsTopic.State (State)
import Core.Mod.NewsTopic.State as NewsTopic
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide state payload = case state of
  NewsTopic.Added _ -> η []
  _ -> η [ NewsTopicAdded { id: payload.id, searchInput: payload.searchInput } ]
