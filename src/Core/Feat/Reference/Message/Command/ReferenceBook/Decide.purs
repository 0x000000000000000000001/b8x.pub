module Core.Feat.Reference.Message.Command.ReferenceBook.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Command.Handle.Upload as Upload
import Core.Feat.Reference.Message.Command.ReferenceBook.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceBook.State (State)
import Core.Mod.Author.Exception.AuthorNotReferenced (AuthorNotReferenced(..))
import Core.Mod.Author.State as Author
import Core.Mod.Book.Exception.BookAlreadyReferenced (BookAlreadyReferenced(..))
import Core.Mod.Book.State as Book
import Core.Mod.Editor.Exception.EditorNotReferenced (EditorNotReferenced(..))
import Core.Mod.Editor.State as Editor
import Data.Foldable (traverse_)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide
  { authors: authorStates, book, editor }
  { id, authors, editor: editorId, name, year, cover: coverUrl, legacyId } = checkEditor
  where
  checkEditor =
    case editorId of
      Just eId ->
        case editor of
          Editor.Referenced _ -> checkAuthors
          _ -> throw $ EditorNotReferenced eId
      Nothing -> checkAuthors

  checkAuthors = do
    traverse_ checkAuthor authors
    checkBook

  checkAuthor authorId = case Map.lookup authorId authorStates of
    Just (Author.Referenced _) -> ηι
    _ -> throw $ AuthorNotReferenced authorId

  checkBook = case book of
    Book.Referenced _ -> throw $ BookAlreadyReferenced Nothing
    _ -> do
      cover <- case coverUrl of
        Just url -> Just <$> Upload.uploadImage false true url
        Nothing -> η Nothing
      η [ BookReferenced { id, name, authors, editor: editorId, year, cover, legacyId } ]

