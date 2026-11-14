module Core.Feat.Reference.Message.Command.CorrectBook.Play where

import Proem

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Feat.Reference.Message.Command.CorrectBook.State (State)
import Core.Mod.Book.State as Book
import Core.Mod.Editor.State as Editor

play :: State -> LoadedEvent -> State
play state { event } = case event of
  BookReferenced { editor, cover } -> state { book = Book.Referenced { editor, cover } }
  BookDereferenced _ -> state { book = Book.Dereferenced }
  BookEditorCorrected { editor } -> state { book = state.book <#> (_ { editor = editor }) }
  BookCoverCorrected { cover } -> state { book = state.book <#> (_ { cover = cover }) }

  EditorReferenced _ -> state { editor = Editor.Referenced ι }
  EditorDereferenced _ -> state { editor = Editor.Dereferenced }

  _ -> state
