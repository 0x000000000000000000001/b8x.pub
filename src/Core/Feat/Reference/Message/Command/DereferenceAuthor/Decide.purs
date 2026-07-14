module Core.Feat.Reference.Message.Command.DereferenceAuthor.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.State (State)
import Core.Mod.Author.Exception.AuthorNotReferenced (AuthorNotReferenced(..))
import Core.Mod.Author.State as Author
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide Author.NotReferencedYet { author } = throw $ AuthorNotReferenced author
decide Author.Dereferenced { author } = throw $ AuthorNotReferenced author
decide (Author.Referenced _) { author } = η [ AuthorDereferenced { author } ]
