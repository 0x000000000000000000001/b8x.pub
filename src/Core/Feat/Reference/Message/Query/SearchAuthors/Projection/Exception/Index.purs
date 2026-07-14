module Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.Index where

import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.InvalidAuthorFilter (InvalidAuthorFilterRow)

type SearchAuthorsProjectionExceptionRow r =
  InvalidAuthorFilterRow
    r