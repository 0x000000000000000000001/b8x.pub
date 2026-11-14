module Core.Feat.Reference.Message.Command.CorrectBook.Decide where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.CorrectBook.Payload (Payload)
import Core.Feat.Reference.Message.Command.CorrectBook.State (BookState, State)
import Core.Message.Command.Corrected (Corrected(..))
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Command.Handle.Upload as Upload
import Core.Mod.Book.Exception.BookNotReferenced (BookNotReferenced(..))
import Core.Mod.Book.State as Book
import Core.Mod.Editor.Exception.EditorNotReferenced (EditorNotReferenced(..))
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.State as Editor
import Data.Array as Array
import Data.Maybe (Maybe(..), isNothing)
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide
  { book, editor }
  { id, editor: editorId, cover: coverCorrection } = checkBook
  where
  checkBook :: Run (UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
  checkBook = case book of
    Book.Referenced current -> do
      editorEvent <- evaluateEditor current
      coverEvent <- evaluateCover current
      η $ Array.catMaybes [ editorEvent, coverEvent ]
    _ -> throw $ BookNotReferenced id

  evaluateEditor :: BookState -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Maybe Event)
  evaluateEditor { editor: currentEditor } = case editorId of
    AsIs -> η Nothing
    Corrected eId -> do
      checkEditor eId
      η $ currentEditor == eId ? Nothing ↔ Just (BookEditorCorrected { book: id, editor: eId })

  checkEditor :: Maybe EditorId -> Run (UPLOAD + EXCEPT_LOGIC + fx) Ɩ
  checkEditor eId = case eId of
    Just innerId -> case editor of
      Editor.Referenced _ -> ηι
      _ -> throw $ EditorNotReferenced innerId
    _ -> ηι

  evaluateCover :: BookState -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Maybe Event)
  evaluateCover { cover: currentCover } = case coverCorrection of
    AsIs -> η Nothing
    Corrected Nothing ->
      η $ isNothing currentCover ? Nothing ↔ Just (BookCoverCorrected { book: id, cover: Nothing })
    Corrected (Just url) -> do
      cover <- Just <$> Upload.uploadImage false true url
      η $ currentCover == cover ? Nothing ↔ Just (BookCoverCorrected { book: id, cover })
