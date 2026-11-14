module Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Index where

import Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Projection (SearchNewsTopicsProjection)

type SearchNewsTopicsProjectionRow r =
  ( searchNewsTopics ∷ SearchNewsTopicsProjection
  | r
  )
