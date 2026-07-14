module Core.Feat.Review.Message.Command.Index where

import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Command (AddArticleToNewsRelatedBlacklist)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Command (AddArticleToNewsRelatedWhitelist)
import Core.Feat.Review.Message.Command.AddNewsTopic.Command (AddNewsTopic)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Command (AddMagazineCustomSection)
import Core.Feat.Review.Message.Command.DiscardArticle.Command (DiscardArticle)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Command (FeatureArticleOnFrontPage)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Command (RemoveNewsTopic)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Command (ScheduleNewsletter)
import Core.Feat.Review.Message.Command.TrackArticleRead.Command (TrackArticleRead)
import Core.Feat.Review.Message.Command.WriteArticle.Command (WriteArticle)
import Core.Feat.Review.Message.Command.QuoteArticle.Command (QuoteArticle)

type ReviewCommandRow r =
  ( discardArticle :: DiscardArticle
  , featureArticleOnFrontPage :: FeatureArticleOnFrontPage
  , writeArticle :: WriteArticle
  , addNewsTopic :: AddNewsTopic
  , addMagazineCustomSection :: AddMagazineCustomSection
  , removeNewsTopic :: RemoveNewsTopic
  , addArticleToNewsRelatedWhitelist :: AddArticleToNewsRelatedWhitelist
  , addArticleToNewsRelatedBlacklist :: AddArticleToNewsRelatedBlacklist
  , trackArticleRead :: TrackArticleRead
  , scheduleNewsletter :: ScheduleNewsletter
  , quoteArticle :: QuoteArticle
  | r
  )
