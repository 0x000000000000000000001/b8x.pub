module Core.Feat.Reference.Message.Command.CorrectAuthor.State where

import Core.Feat.Reference.Message.Command.CorrectAuthor.Payload as CorrectAuthor
import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.State as Author

type State =
  { author :: Author.State Biography
  }

initialState :: CorrectAuthor.Payload -> State
initialState _ =
  { author: Author.initialState
  }
