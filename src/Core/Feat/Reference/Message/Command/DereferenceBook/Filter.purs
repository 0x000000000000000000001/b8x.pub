module Core.Feat.Reference.Message.Command.DereferenceBook.Filter where

import Proem hiding ((&&))

import Core.Event.Filter (Filter)
import Core.Feat.Reference.Message.Command.DereferenceBook.Payload (Payload)
import Core.Mod.Book.State as Book

filter :: Payload -> Filter
filter { book } = Book.filter book
