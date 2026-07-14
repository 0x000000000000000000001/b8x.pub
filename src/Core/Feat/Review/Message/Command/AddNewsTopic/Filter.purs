module Core.Feat.Review.Message.Command.AddNewsTopic.Filter where

import Proem hiding ((&&), (||))

import Core.Event.NewsTopicAdded.NewsTopicAdded (NewsTopicAdded)
import Core.Event.NewsTopicRemoved.NewsTopicRemoved (NewsTopicRemoved)
import Core.Event.Filter (Filter(..), by)
import Core.Feat.Review.Message.Command.AddNewsTopic.Payload (Payload)

filter :: Payload -> Filter
filter { id } = Or (by @NewsTopicAdded @"id" id) (by @NewsTopicRemoved @"newsTopic" id)
