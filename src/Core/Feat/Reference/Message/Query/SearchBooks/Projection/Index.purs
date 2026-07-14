module Core.Feat.Reference.Message.Query.SearchBooks.Projection.Index where

import Core.Feat.Reference.Message.Query.SearchBooks.Projection.Projection (SearchBooksProjection)

type SearchBooksProjectionRow r =
  ( searchBooks ∷ SearchBooksProjection
  | r
  )
