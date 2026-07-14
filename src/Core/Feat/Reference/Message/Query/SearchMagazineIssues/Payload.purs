module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Payload where

import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Message.Field.Filter (Filter, FilterField)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Message.Field.Sort (Sort, SortField)
import Core.Mod.MagazineIssue.Id.Message.Field.AfterMagazineIssue (AfterMagazineIssue, AfterMagazineIssueField)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Field.Needs (Needs, NeedsField)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { sort :: Sort
  , filter :: Filter
  , limit :: BoundedLimit
  , after :: AfterMagazineIssue
  , needs :: Needs
  , expectation :: Expectation
  }

type Fields =
  ( sort :: SortField
  , filter :: FilterField
  , limit :: BoundedLimitField
  , after :: AfterMagazineIssueField
  , needs :: NeedsField
  , expectation :: ExpectationField
  )
