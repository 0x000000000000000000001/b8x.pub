module Core.Feat.Reference.Message.Query.SearchAuthors.Payload where

import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Mod.Author.Id.Message.Field.After (AfterAuthorField, AfterAuthor)
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Message.Field.Filter (Filter, FilterField)
import Core.Feat.Reference.Message.Query.SearchAuthors.Field.Needs (Needs, NeedsField)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { filter :: Filter
  , limit :: BoundedLimit
  , after :: AfterAuthor
  , needs :: Needs
  , expectation :: Expectation
  }

type Fields =
  (filter :: FilterField
  , limit :: BoundedLimitField
  , after :: AfterAuthorField
  , needs :: NeedsField
  , expectation :: ExpectationField
  )
