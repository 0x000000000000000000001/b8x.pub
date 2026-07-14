module Core.Feat.Reference.Message.Command.ReferenceEditor.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Reference.Message.Command.ReferenceEditor.State (State)
import Core.Mod.Editor.State as Editor

play :: State -> LoadedEvent -> State
play = Editor.play
