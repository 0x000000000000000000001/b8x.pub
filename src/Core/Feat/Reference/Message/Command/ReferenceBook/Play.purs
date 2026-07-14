module Core.Feat.Reference.Message.Command.ReferenceBook.Play where

import Core.Event.Event (LoadedEvent, Event(..))
import Core.Feat.Reference.Message.Command.ReferenceBook.State (State)
import Core.Mod.Author.State as Author
import Core.Mod.Book.State as Book
import Core.Mod.Editor.State as Editor
import Data.Map as Map
import Data.Maybe (Maybe(..))

play :: State -> LoadedEvent -> State
play { authors, book, editor } e@{ event } =
  { authors: case event of
      AuthorReferenced p -> Map.update (\s -> Just (Author.play s e)) p.id authors
      AuthorDereferenced p -> Map.update (\s -> Just (Author.play s e)) p.author authors
      _ -> authors
  , book: Book.play book e
  , editor: Editor.play editor e
  }

