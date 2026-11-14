module Core.Feat.Reference.Message.Command.CorrectBook.Filter where

import Proem hiding ((&&), (||))

import Core.Event.BookCoverCorrected.BookCoverCorrected (BookCoverCorrected)
import Core.Event.BookEditorCorrected.BookEditorCorrected (BookEditorCorrected)
import Core.Event.Filter (Filter(..), by)
import Core.Feat.Reference.Message.Command.CorrectBook.Payload (Payload)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.State as Book
import Core.Mod.Editor.State as Editor
import Core.Message.Command.Corrected (Corrected(..))
import Data.Maybe (Maybe(..))

filter :: Payload -> Filter
filter { id, editor } =
  case editor of
    Corrected (Just eId) -> Or (bookFilter id) (Editor.filter eId)
    _ -> bookFilter id

bookFilter :: BookId -> Filter
bookFilter id =
  Or (Book.filter id)
    (Or (by @BookEditorCorrected @"book" id) (by @BookCoverCorrected @"book" id))
