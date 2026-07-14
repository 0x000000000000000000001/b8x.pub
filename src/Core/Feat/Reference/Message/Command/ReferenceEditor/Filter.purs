module Core.Feat.Reference.Message.Command.ReferenceEditor.Filter where

import Proem hiding ((&&))

import Core.Event.Filter (Filter)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Payload (Payload)
import Core.Mod.Editor.State as Editor

filter :: Payload -> Filter
filter { id } = Editor.filter id
