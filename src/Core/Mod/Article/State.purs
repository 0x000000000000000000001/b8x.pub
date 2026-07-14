module Core.Mod.Article.State where

import Proem hiding ((&&), (||))

import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Event.Filter (Filter(..), by)
import Core.Event.ArticleDiscarded.ArticleDiscarded (ArticleDiscarded)
import Core.Event.ArticleWritten.ArticleWritten (ArticleWritten)
import Core.Mod.Article.Id.Id (ArticleId)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data State a
  = NotWrittenYet
  | Written a
  | Discarded

derive instance Eq a => Eq (State a)
derive instance Generic (State a) _
derive instance Functor State

instance Show a => Show (State a) where
  show = genericShow

initialState :: ∀ a. State a
initialState = NotWrittenYet

filter :: ArticleId -> Filter
filter id =
  Or (by @ArticleWritten @"id" id)
    (by @ArticleDiscarded @"article" id)

play :: State Ɩ -> LoadedEvent -> State Ɩ
play state { event } = case state, event of
  _, Event.ArticleWritten _ -> Written ι
  _, Event.ArticleDiscarded _ -> Discarded
  _, _ -> state
