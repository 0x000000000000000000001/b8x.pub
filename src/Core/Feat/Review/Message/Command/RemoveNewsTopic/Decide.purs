module Core.Feat.Review.Message.Command.RemoveNewsTopic.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Payload (Payload)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.State (State)
import Core.Mod.NewsTopic.Exception.NewsTopicNotAdded (NewsTopicNotAdded(..))
import Core.Mod.NewsTopic.State as NewsTopic
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide NewsTopic.NotAddedYet { newsTopic } = throw $ NewsTopicNotAdded newsTopic
decide NewsTopic.Removed { newsTopic } = throw $ NewsTopicNotAdded newsTopic
decide (NewsTopic.Added _) { newsTopic } = η [ NewsTopicRemoved { newsTopic } ]
