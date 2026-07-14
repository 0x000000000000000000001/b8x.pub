module Core.Feat.Review.Message.Query.SearchArticles.Payload where

import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Mod.Article.Id.Message.Field.After (AfterArticleField, AfterArticle)
import Core.Feat.Review.Message.Query.SearchArticles.Field.Filter (Filter, FilterField)
import Core.Feat.Review.Message.Query.SearchArticles.Field.Needs (Needs, NeedsField)
import Core.Feat.Review.Message.Query.SearchArticles.Field.Sort (SortField, Sort)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { sort :: Sort
  , filter :: Filter
  , expectation :: Expectation
  , limit :: BoundedLimit
  , after :: AfterArticle
  , needs :: Needs
  }

type Fields =
  ( sort :: SortField
  , filter :: FilterField
  , expectation :: ExpectationField
  , limit :: BoundedLimitField
  , after :: AfterArticleField
  , needs :: NeedsField
  )
