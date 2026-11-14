module Core.Feat.Review.Message.Query.Exception.Index where

import Core.Feat.Review.Message.Query.SearchNewsTopics.Exception.Index (SearchNewsTopicsQueryExceptionRow)
import Type.Row (type (+))

type ReviewQueryExceptionRow r =
  SearchNewsTopicsQueryExceptionRow
    + r
