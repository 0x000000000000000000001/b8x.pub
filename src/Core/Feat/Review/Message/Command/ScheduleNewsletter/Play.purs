module Core.Feat.Review.Message.Command.ScheduleNewsletter.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.State (State)
import Core.Mod.Newsletter.State as Newsletter

play :: State -> LoadedEvent -> State
play state e = Newsletter.play state e
