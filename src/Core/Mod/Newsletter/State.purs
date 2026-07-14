module Core.Mod.Newsletter.State where

import Proem hiding ((&&), (||))

import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter, by)
import Core.Event.NewsletterScheduled.NewsletterScheduled (NewsletterScheduled)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data State a
  = NotScheduledYet
  | Scheduled a
  | Unscheduled

derive instance Eq a => Eq (State a)
derive instance Generic (State a) _
derive instance Functor State

instance Show a => Show (State a) where
  show = genericShow

initialState :: ∀ a. State a
initialState = NotScheduledYet

filter :: NewsletterId -> Filter
filter id = by @NewsletterScheduled @"id" id

play :: State Ɩ -> LoadedEvent -> State Ɩ
play state { event } = case state, event of
  _, Event.NewsletterScheduled _ -> Scheduled ι
  _, _ -> state
