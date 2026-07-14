module Core.Feat.Review.Message.Command.WriteArticle.Projection.Index where

import Core.Feat.Review.Message.Command.WriteArticle.Projection.Projection (WriteArticleProjection)

type WriteArticleProjectionRow r =
  ( writeArticle :: WriteArticleProjection
  | r
  )
