module Core.Feat.Reference.Message.Command.DereferenceAuthor.State where

import Proem

import Core.Feat.Reference.Message.Command.DereferenceAuthor.Payload as DereferenceAuthor
import Core.Mod.Author.State as Author

type State = Author.State Ɩ

initialState :: DereferenceAuthor.Payload -> State
initialState _ = Author.initialState
