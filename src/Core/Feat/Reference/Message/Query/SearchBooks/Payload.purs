module Core.Feat.Reference.Message.Query.SearchBooks.Payload where

import Core.Feat.Reference.Message.Query.SearchBooks.Field.Filter (Filter, FilterField)
import Core.Mod.Book.Id.Message.Field.AfterBook (AfterBook, AfterBookField)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Feat.Reference.Message.Query.SearchBooks.Field.Needs (Needs, NeedsField)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { filter :: Filter
  , limit :: BoundedLimit
  , after :: AfterBook
  , needs :: Needs
  , expectation :: Expectation
  }

type Fields =
  ( filter :: FilterField
  , limit :: BoundedLimitField
  , after :: AfterBookField
  , needs :: NeedsField
  , expectation :: ExpectationField
  )
