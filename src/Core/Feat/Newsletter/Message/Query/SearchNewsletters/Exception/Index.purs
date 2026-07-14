module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Exception.Index where

import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Exception.InvalidNewsletterFilter (InvalidNewsletterFilterRow)
import Type.Row (type (+))

type SearchNewslettersExceptionRow r =
  InvalidNewsletterFilterRow
    + r
