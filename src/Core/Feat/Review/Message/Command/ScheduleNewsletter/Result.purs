module Core.Feat.Review.Message.Command.ScheduleNewsletter.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Payload (Payload)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.State (State)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Partial.Unsafe (unsafeCrashWith)
import Run (Run)

type Result = { id :: NewsletterId }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run fx Result
toResult _ _ events = do
  let ev = head events
  case ev of
    Just (NewsletterScheduled { id }) -> η { id }
    _ -> unsafeCrashWith "Expected NewsletterScheduled event"
