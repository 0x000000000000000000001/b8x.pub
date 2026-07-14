module Core.Mod.Author.State where

import Proem hiding ((&&), (||))

import Core.Event.AuthorDereferenced.AuthorDereferenced (AuthorDereferenced)
import Core.Event.AuthorReferenced.AuthorReferenced (AuthorReferenced)
import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter(..), by)
import Core.Mod.Author.Id.Id (AuthorId)
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

filter :: AuthorId -> Filter
filter id =
  Or (by @AuthorReferenced @"id" id)
    (by @AuthorDereferenced @"author" id)

play :: State Ɩ -> LoadedEvent -> State Ɩ
play state { event } = case state, event of
  _, Event.AuthorReferenced _ -> Referenced ι
  _, Event.AuthorDereferenced _ -> Dereferenced
  _, _ -> state
