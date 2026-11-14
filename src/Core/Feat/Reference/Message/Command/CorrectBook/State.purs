module Core.Feat.Reference.Message.Command.CorrectBook.State where

import Proem

import Core.Feat.Reference.Message.Command.CorrectBook.Payload as CorrectBook
import Core.Mod.Book.State as Book
import Core.Mod.Editor.State as Editor
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Image.Image (Image)
import Data.Maybe (Maybe)

type BookState =
  { editor :: Maybe EditorId
  , cover :: Maybe Image
  }

type State =
  { book :: Book.State BookState
  , editor :: Editor.State Ɩ
  }

initialState :: CorrectBook.Payload -> State
initialState _ =
  { book: Book.initialState
  , editor: Editor.initialState
  }
