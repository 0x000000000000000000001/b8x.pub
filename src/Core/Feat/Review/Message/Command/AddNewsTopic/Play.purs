module Core.Feat.Review.Message.Command.AddNewsTopic.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Review.Message.Command.AddNewsTopic.State (State)
import Core.Mod.NewsTopic.State as NewsTopic

play :: State -> LoadedEvent -> State
play state loadedEvent = NewsTopic.play state loadedEvent
