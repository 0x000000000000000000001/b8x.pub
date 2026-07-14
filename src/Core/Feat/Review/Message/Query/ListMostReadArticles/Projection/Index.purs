module Core.Feat.Review.Message.Query.ListMostReadArticles.Projection.Index where

import Core.Feat.Review.Message.Query.ListMostReadArticles.Projection.Projection (ListMostReadArticlesProjection)
type ListMostReadArticlesProjectionRow r
  = ( listMostReadArticles :: ListMostReadArticlesProjection
    | r
    )
