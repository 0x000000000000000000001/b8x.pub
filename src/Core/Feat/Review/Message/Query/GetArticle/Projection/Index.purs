module Core.Feat.Review.Message.Query.GetArticle.Projection.Index where

import Core.Feat.Review.Message.Query.GetArticle.Projection.Projection (GetArticleProjection)

type GetArticleProjectionRow r =
  ( getArticle :: GetArticleProjection
  | r
  )
