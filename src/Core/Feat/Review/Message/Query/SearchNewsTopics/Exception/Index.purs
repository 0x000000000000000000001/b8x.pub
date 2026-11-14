module Core.Feat.Review.Message.Query.SearchNewsTopics.Exception.Index where

import Core.Feat.Review.Message.Query.SearchNewsTopics.Exception.InvalidNewsTopicFilter (InvalidNewsTopicFilterRow)

type SearchNewsTopicsQueryExceptionRow r =
  ( | InvalidNewsTopicFilterRow r
  )
