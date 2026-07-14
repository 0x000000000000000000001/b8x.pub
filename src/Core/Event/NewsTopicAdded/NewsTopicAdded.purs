module Core.Event.NewsTopicAdded.NewsTopicAdded where

import Core.Event.Event (class IsEvent)
import Core.Event.NewsTopicAdded.Payload (Payload)
import Util.Type.Type (class Reflect)

data NewsTopicAdded

instance IsEvent NewsTopicAdded Payload

instance Reflect NewsTopicAdded where
  reflectName = "NewsTopicAdded"
