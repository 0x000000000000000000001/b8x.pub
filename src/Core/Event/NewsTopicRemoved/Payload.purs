module Core.Event.NewsTopicRemoved.Payload where

import Core.Mod.NewsTopic.Id.Id (NewsTopicId)

type Payload =
  { newsTopic :: NewsTopicId
  }
