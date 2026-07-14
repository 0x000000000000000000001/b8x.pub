module Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Index where

import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection (SearchAuthorsProjection)

type SearchAuthorsProjectionRow r =
  ( searchAuthors ∷ SearchAuthorsProjection
  | r
  )