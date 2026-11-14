module Core.Feat.Reference.Message.Command.CorrectAuthor.Play where

import Proem

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Feat.Reference.Message.Command.CorrectAuthor.State (State)
import Core.Mod.Author.State as Author

play :: State -> LoadedEvent -> State
play state { event } = case event of
  AuthorReferenced { biography } -> state { author = Author.Referenced biography }
  AuthorDereferenced _ -> state { author = Author.Dereferenced }
  AuthorBiographyCorrected { biography } -> state { author = state.author <#> (κ biography) }

  _ -> state
