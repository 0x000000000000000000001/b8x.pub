module Core.Feat.Reference.Message.Command.ReferenceEditor.State where

import Proem

import Core.Feat.Reference.Message.Command.ReferenceEditor.Payload as ReferenceEditor
import Core.Mod.Editor.State as Editor

type State = Editor.State Ɩ

initialState :: ReferenceEditor.Payload -> State
initialState _ = Editor.initialState
