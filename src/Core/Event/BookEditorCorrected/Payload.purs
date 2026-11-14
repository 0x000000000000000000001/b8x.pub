module Core.Event.BookEditorCorrected.Payload where

import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Editor.Id.Id (EditorId)
import Data.Maybe (Maybe)

type Payload =
  { book :: BookId
  , editor :: Maybe EditorId
  }
