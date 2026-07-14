module Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Index where

import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Projection (ListNewsRelatedArticlesProjection)

type ListNewsRelatedArticlesProjectionRow r =
  ( listNewsRelatedArticles :: ListNewsRelatedArticlesProjection
  | r
  )
