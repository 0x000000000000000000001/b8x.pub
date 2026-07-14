module Core.Feat.Reference.Message.Command.ReferenceAuthor.State where

import Proem

import Core.Mod.Author.State as Author
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Payload as ReferenceAuthor

type State = Author.State Ɩ

initialState :: ReferenceAuthor.Payload -> State
initialState _ = Author.initialState
