module Core.Feat.Review.Message.Query.SearchNewsTopics.Payload where

import Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Message.Field.Filter (NewsTopicFilterField, Filter)
import Core.Mod.NewsTopic.Id.Message.Field.AfterNewsTopic (AfterNewsTopic, AfterNewsTopicField)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Feat.Review.Message.Query.SearchNewsTopics.Field.Needs (Needs, NeedsField)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { filter :: Filter
  , limit :: BoundedLimit
  , after :: AfterNewsTopic
  , needs :: Needs
  , expectation :: Expectation
  }

type Fields =
  (filter :: NewsTopicFilterField
  , limit :: BoundedLimitField
  , after :: AfterNewsTopicField
  , needs :: NeedsField
  , expectation :: ExpectationField
  )
