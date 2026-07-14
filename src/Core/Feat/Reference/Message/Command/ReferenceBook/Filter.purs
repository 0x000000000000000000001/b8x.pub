module Core.Feat.Reference.Message.Command.ReferenceBook.Filter where

import Proem hiding ((&&), (||))

import Core.Event.Filter (Filter(..))
import Core.Feat.Reference.Message.Command.ReferenceBook.Payload (Payload)
import Core.Mod.Author.State as Author
import Core.Mod.Book.State as Book
import Core.Mod.Editor.State as Editor
import Data.Foldable (foldl)
import Data.Maybe (Maybe(..))

filter :: Payload -> Filter
filter { id, authors, editor } =
  let
    baseFilter = case editor of
      Just eId -> Or (Book.filter id) (Editor.filter eId)
      Nothing -> Book.filter id
  in
    foldl Or baseFilter (Author.filter <$> authors)

