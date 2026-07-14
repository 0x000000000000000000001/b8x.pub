module Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Index where

import Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Projection (ListYearArticlesProjection)

type ListYearArticlesProjectionRow r =
  ( listYearArticles :: ListYearArticlesProjection
  | r
  )
