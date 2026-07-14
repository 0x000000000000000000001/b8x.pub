module Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Index where

import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Projection (ListMagazineIssuesProjection)

type ListMagazineIssuesProjectionRow r =
  ( listMagazineIssues :: ListMagazineIssuesProjection
  | r
  )
