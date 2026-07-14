module Core.Mod.MagazineIssue.State where

import Proem hiding ((||))

import Core.Event.MagazineIssueDereferenced.MagazineIssueDereferenced (MagazineIssueDereferenced)
import Core.Event.MagazineIssueReferenced.MagazineIssueReferenced (MagazineIssueReferenced)
import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter(..), by)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
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

filter :: MagazineIssueId -> Filter
filter id =
  Or (by @MagazineIssueReferenced @"id" id)
    (by @MagazineIssueDereferenced @"issue" id)

play :: State Ɩ -> LoadedEvent -> State Ɩ
play state { event } = case state, event of
  _, Event.MagazineIssueReferenced _ -> Referenced ι
  _, Event.MagazineIssueDereferenced _ -> Dereferenced
  _, _ -> state
