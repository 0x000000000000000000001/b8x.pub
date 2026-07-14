module Core.Feat.Review.Message.Command.ScheduleNewsletter.Decide where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Payload (Payload)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.State (State)
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide _ { id, scheduledFor, articles } = η
  [ NewsletterScheduled
      { id
      , scheduledFor
      , articles
      }
  ]
