module Core.Feat.Reference.Message.Command.DereferenceAuthor.Filter where

import Proem hiding ((&&))

import Core.Event.Filter (Filter)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Payload (Payload)
import Core.Mod.Author.State as Author

filter :: Payload -> Filter
filter { author } = Author.filter author
