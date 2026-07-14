module Core.Mod.NewsTopic.State where

import Proem hiding ((&&), (||))

import Core.Event.NewsTopicRemoved.NewsTopicRemoved (NewsTopicRemoved)
import Core.Event.NewsTopicAdded.NewsTopicAdded (NewsTopicAdded)
import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter(..), by)
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data State a
  = NotAddedYet
  | Added a
  | Removed

derive instance Eq a => Eq (State a)
derive instance Generic (State a) _
derive instance Functor State

instance Show a => Show (State a) where
  show = genericShow

initialState :: ∀ a. State a
initialState = NotAddedYet

filter :: NewsTopicId -> Filter
filter id =
  Or (by @NewsTopicAdded @"id" id)
    (by @NewsTopicRemoved @"newsTopic" id)

play :: State Ɩ -> LoadedEvent -> State Ɩ
play state { event } = case state, event of
  _, Event.NewsTopicAdded _ -> Added ι
  _, Event.NewsTopicRemoved _ -> Removed
  _, _ -> state
