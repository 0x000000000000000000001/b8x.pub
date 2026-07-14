module Core.Feat.Reference.Message.Command.DereferenceEditor.State where

import Proem

import Core.Mod.Editor.State as Editor
import Core.Feat.Reference.Message.Command.DereferenceEditor.Payload as DereferenceEditor

type State = Editor.State Ɩ

initialState :: DereferenceEditor.Payload -> State
initialState _ = Editor.initialState
