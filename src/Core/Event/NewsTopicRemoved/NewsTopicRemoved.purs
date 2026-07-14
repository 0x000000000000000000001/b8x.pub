module Core.Event.NewsTopicRemoved.NewsTopicRemoved where

import Core.Event.Event (class IsEvent)
import Core.Event.NewsTopicRemoved.Payload (Payload)
import Util.Type.Type (class Reflect)

data NewsTopicRemoved

instance IsEvent NewsTopicRemoved Payload

instance Reflect NewsTopicRemoved where
  reflectName = "NewsTopicRemoved"
