module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Filter where

import Proem hiding ((&&), (||))

import Core.Event.Filter (Filter(..), by)
import Core.Event.ArticleAddedToNewsRelatedBlacklist.ArticleAddedToNewsRelatedBlacklist (ArticleAddedToNewsRelatedBlacklist)
import Core.Event.ArticleRemovedFromNewsRelatedBlacklist.ArticleRemovedFromNewsRelatedBlacklist (ArticleRemovedFromNewsRelatedBlacklist)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Payload (Payload)

filter :: Payload -> Filter
filter { article } =
  Or (by @ArticleAddedToNewsRelatedBlacklist @"article" article)
    (by @ArticleRemovedFromNewsRelatedBlacklist @"article" article)
