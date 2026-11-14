module Core.Feat.Review.Message.Query.SearchNewsTopics.Result where

import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Core.Mod.NewsTopic.SearchInput.SearchInput (SearchInput)
import Core.Message.Query.Result (Return)

type Result =
  { newsTopics ::
      Array
        { id :: Return NewsTopicId
        , searchInput :: Return SearchInput
        }
  , limit :: Int
  , hasNextPage :: Boolean
  }
