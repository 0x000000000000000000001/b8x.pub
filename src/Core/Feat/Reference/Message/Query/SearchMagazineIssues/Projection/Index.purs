module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Index where

import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Projection (SearchMagazineIssuesProjection)

type SearchMagazineIssuesProjectionRow r =
  ( searchMagazineIssues :: SearchMagazineIssuesProjection
  | r
  )
