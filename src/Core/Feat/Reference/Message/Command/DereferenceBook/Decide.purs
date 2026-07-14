module Core.Feat.Reference.Message.Command.DereferenceBook.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.DereferenceBook.Payload (Payload)
import Core.Feat.Reference.Message.Command.DereferenceBook.State (State)
import Core.Mod.Book.Exception.BookNotReferenced (BookNotReferenced(..))
import Core.Mod.Book.State as Book
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide Book.NotReferencedYet { book } = throw $ BookNotReferenced book
decide Book.Dereferenced { book } = throw $ BookNotReferenced book
decide (Book.Referenced _) { book } = η [ BookDereferenced { book } ]
