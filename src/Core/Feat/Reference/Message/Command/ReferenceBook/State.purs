module Core.Feat.Reference.Message.Command.ReferenceBook.State where

import Proem

import Core.Feat.Reference.Message.Command.ReferenceBook.Payload as ReferenceBook
import Core.Mod.Author.State as Author
import Core.Mod.Book.State as Book
import Core.Mod.Editor.State as Editor
import Data.Map as Map
import Data.Tuple (Tuple(..))
import Core.Mod.Author.Id.Id (AuthorId)

type State =
  { authors :: Map.Map AuthorId (Author.State Ɩ)
  , book :: Book.State Ɩ
  , editor :: Editor.State Ɩ
  }

initialState :: ReferenceBook.Payload -> State
initialState payload =
  { authors: Map.fromFoldable (payload.authors <#> \a -> Tuple a Author.initialState)
  , book: Book.initialState
  , editor: Editor.initialState
  }

