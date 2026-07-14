module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Payload where

import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Mod.Newsletter.Id.Message.Field.After (AfterNewsletterField, AfterNewsletter)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Field.Filter (Filter, FilterField)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Field.Needs (Needs, NeedsField)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Field.Sort (SortField, Sort)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { sort :: Sort
  , filter :: Filter
  , expectation :: Expectation
  , limit :: BoundedLimit
  , after :: AfterNewsletter
  , needs :: Needs
  }

type Fields =
  (sort :: SortField
  , filter :: FilterField
  , expectation :: ExpectationField
  , limit :: BoundedLimitField
  , after :: AfterNewsletterField
  , needs :: NeedsField
  )
