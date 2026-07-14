module Core.Feat.Reference.Message.Command.DereferenceAuthor.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.State (State)
import Core.Mod.Author.State as Author

play :: State -> LoadedEvent -> State
play = Author.play
