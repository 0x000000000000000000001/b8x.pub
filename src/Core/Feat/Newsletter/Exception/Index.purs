module Core.Feat.Newsletter.Exception.Index where

import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Exception.Index (SearchNewslettersExceptionRow)
import Type.Row (type (+))

type NewsletterExceptionRow r =
  SearchNewslettersExceptionRow
    + r
