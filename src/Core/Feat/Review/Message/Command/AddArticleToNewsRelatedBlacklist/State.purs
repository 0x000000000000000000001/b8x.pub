module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.State where

import Proem

import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Payload as AddArticleToNewsRelatedBlacklist
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data State
  = NotAddedYet
  | Added
  | Removed

derive instance Eq State
derive instance Generic State _

instance Show State where
  show = genericShow

initialState :: AddArticleToNewsRelatedBlacklist.Payload -> State
initialState _ = NotAddedYet
