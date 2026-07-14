module Core.Feat.Reference.Message.Command.DereferenceBook.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Reference.Message.Command.DereferenceBook.State (State)
import Core.Mod.Book.State as Book

play :: State -> LoadedEvent -> State
play = Book.play
