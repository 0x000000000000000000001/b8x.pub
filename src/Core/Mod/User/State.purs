module Core.Mod.User.State where

import Proem hiding ((&&), (||))

import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter(..), by)
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Core.Event.UserUnregistered.UserUnregistered (UserUnregistered)
import Core.Mod.User.Id.Id (UserId)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data State a
  = NotRegisteredYet
  | Registered a
  | Unregistered

derive instance Eq a => Eq (State a)
derive instance Generic (State a) _
derive instance Functor State

instance Show a => Show (State a) where
  show = genericShow

initialState :: ∀ a. State a
initialState = NotRegisteredYet

filter :: UserId -> Filter
filter userId =
  Or (by @UserRegistered @"id" userId)
    (by @UserUnregistered @"user" userId)

play :: ∀ state. (state -> State Ɩ) -> (state -> State Ɩ -> state) -> LoadedEvent -> state -> state
play get set { event } state = case get state, event of
  _, Event.UserRegistered _ -> set state $ Registered ι
  _, Event.UserUnregistered _ -> set state Unregistered
  _, _ -> state

playUserId :: ∀ state. (state -> State UserId) -> (state -> State UserId -> state) -> LoadedEvent -> state -> state
playUserId get set { event } state = case get state, event of
  _, Event.UserRegistered p -> set state $ Registered p.id
  _, Event.UserUnregistered _ -> set state Unregistered
  _, _ -> state
