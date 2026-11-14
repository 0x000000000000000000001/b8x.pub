module Core.Feat.Review.Message.Command.Index where

import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Command (AddArticleToNewsRelatedBlacklist)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Command (AddArticleToNewsRelatedWhitelist)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Command (AddMagazineCustomSection)
import Core.Feat.Review.Message.Command.AddNewsTopic.Command (AddNewsTopic, AddNewsTopicAliasRow)
import Core.Feat.Review.Message.Command.CorrectArticle.Command (CorrectArticle, CorrectArticleAliasRow)
import Core.Feat.Review.Message.Command.DiscardArticle.Command (DiscardArticle, DiscardArticleAliasRow)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Command (FeatureArticleOnFrontPage, FeatureArticleOnFrontPageAliasRow)
import Core.Feat.Review.Message.Command.QuoteArticle.Command (QuoteArticle, QuoteArticleAliasRow)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Command (RemoveNewsTopic, RemoveNewsTopicAliasRow)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Command (ScheduleNewsletter, ScheduleNewsletterAliasRow)
import Core.Feat.Review.Message.Command.TrackArticleRead.Command (TrackArticleRead)
import Core.Feat.Review.Message.Command.WriteArticle.Command (WriteArticle, WriteArticleAliasRow)
import Type.Row (type (+))

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
  , correctArticle :: CorrectArticle
  | r
  )

type ReviewCommandAliasRow r =
  AddNewsTopicAliasRow
    + CorrectArticleAliasRow
    + DiscardArticleAliasRow
    + FeatureArticleOnFrontPageAliasRow
    + QuoteArticleAliasRow
    + RemoveNewsTopicAliasRow
    + ScheduleNewsletterAliasRow
    + WriteArticleAliasRow
    + r
