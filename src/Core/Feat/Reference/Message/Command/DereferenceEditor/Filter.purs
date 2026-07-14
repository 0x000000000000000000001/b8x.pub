module Core.Feat.Reference.Message.Command.DereferenceEditor.Filter where

import Proem hiding ((&&))

import Core.Event.Filter (Filter)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Payload (Payload)
import Core.Mod.Editor.State as Editor

filter :: Payload -> Filter
filter { editor } = Editor.filter editor
