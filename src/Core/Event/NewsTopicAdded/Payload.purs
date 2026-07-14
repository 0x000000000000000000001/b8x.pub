module Core.Event.NewsTopicAdded.Payload where

import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Core.Mod.NewsTopic.SearchInput.SearchInput (SearchInput)

type Payload =
  { id :: NewsTopicId
  , searchInput :: SearchInput
  }
