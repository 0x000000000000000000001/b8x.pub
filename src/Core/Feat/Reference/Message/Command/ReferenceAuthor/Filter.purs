module Core.Feat.Reference.Message.Command.ReferenceAuthor.Filter where

import Proem hiding ((&&))

import Core.Event.Filter (Filter)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Payload (Payload)
import Core.Mod.Author.State as Author

filter :: Payload -> Filter
filter { id } = Author.filter id
