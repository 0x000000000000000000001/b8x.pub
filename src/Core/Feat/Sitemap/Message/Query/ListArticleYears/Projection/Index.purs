module Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Index where

import Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Projection (ListArticleYearsProjection)

type ListArticleYearsProjectionRow r =
  ( listArticleYears :: ListArticleYearsProjection
  | r
  )
