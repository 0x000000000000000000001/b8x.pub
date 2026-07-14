module Core.Mod.Editor.State where

import Proem hiding ((&&), (||))

import Core.Event.EditorDereferenced.EditorDereferenced (EditorDereferenced)
import Core.Event.EditorReferenced.EditorReferenced (EditorReferenced)
import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter(..), by)
import Core.Mod.Editor.Id.Id (EditorId)
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

filter :: EditorId -> Filter
filter id =
  Or (by @EditorReferenced @"id" id)
    (by @EditorDereferenced @"editor" id)

play :: State Ɩ -> LoadedEvent -> State Ɩ
play state { event } = case state, event of
  _, Event.EditorReferenced _ -> Referenced ι
  _, Event.EditorDereferenced _ -> Dereferenced
  _, _ -> state
