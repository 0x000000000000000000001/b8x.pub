module Core.Feat.Reference.Message.Query.SearchBooks.Exception.Index where

import Core.Feat.Reference.Message.Query.SearchBooks.Exception.InvalidBookFilter (InvalidBookFilterRow)

type SearchBooksQueryExceptionRow r =
  ( | InvalidBookFilterRow r
  )
