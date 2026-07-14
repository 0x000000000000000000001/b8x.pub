module Core.Feat.Reference.Message.Command.ReferenceAuthor.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.State (State)
import Core.Mod.Author.State as Author

play :: State -> LoadedEvent -> State
play = Author.play
