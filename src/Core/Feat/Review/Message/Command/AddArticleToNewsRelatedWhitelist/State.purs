module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.State where

import Proem

import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Payload as AddArticleToNewsRelatedWhitelist
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

initialState :: AddArticleToNewsRelatedWhitelist.Payload -> State
initialState _ = NotAddedYet
