module Core.Feat.Review.Message.Command.RemoveNewsTopic.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.State (State)
import Core.Mod.NewsTopic.State as NewsTopic

play :: State -> LoadedEvent -> State
play = NewsTopic.play
