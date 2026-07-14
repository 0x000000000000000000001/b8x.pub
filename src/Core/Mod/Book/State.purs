module Core.Mod.Book.State where

import Proem hiding ((&&), (||))

import Core.Event.BookDereferenced.BookDereferenced (BookDereferenced)
import Core.Event.BookReferenced.BookReferenced (BookReferenced)
import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter(..), by)
import Core.Mod.Book.Id.Id (BookId)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data State a
  = NotReferencedYet
  | Referenced a
  | Dereferenced

derive instance Eq a => Eq (State a)
derive instance Generic (State a) _
derive instance Functor State

instance Show a => Show (State a) where
  show = genericShow

initialState :: ∀ a. State a
initialState = NotReferencedYet

filter :: BookId -> Filter
filter id =
  Or (by @BookReferenced @"id" id)
    (by @BookDereferenced @"book" id)

play :: State Ɩ -> LoadedEvent -> State Ɩ
play state { event } = case state, event of
  _, Event.BookReferenced _ -> Referenced ι
  _, Event.BookDereferenced _ -> Dereferenced
  _, _ -> state
