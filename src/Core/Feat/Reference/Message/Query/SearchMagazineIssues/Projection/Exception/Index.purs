module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Exception.Index where

import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Exception.InvalidMagazineIssueFilter (InvalidMagazineIssueFilterRow)
import Type.Row (type (+))

type SearchMagazineIssuesExceptionRow r =
  InvalidMagazineIssueFilterRow
    + r
