module Core.Feat.Review.Message.Query.SearchArticles.Projection.Index where

import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection (SearchArticlesProjection)

type SearchArticlesProjectionRow r =
  ( searchArticles :: SearchArticlesProjection
  | r
  )
