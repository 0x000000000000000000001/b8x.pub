module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Filter where

import Proem hiding ((&&), (||))

import Core.Event.Filter (Filter(..), by)
import Core.Event.ArticleAddedToNewsRelatedWhitelist.ArticleAddedToNewsRelatedWhitelist (ArticleAddedToNewsRelatedWhitelist)
import Core.Event.ArticleRemovedFromNewsRelatedWhitelist.ArticleRemovedFromNewsRelatedWhitelist (ArticleRemovedFromNewsRelatedWhitelist)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Payload (Payload)

filter :: Payload -> Filter
filter { article } =
  Or (by @ArticleAddedToNewsRelatedWhitelist @"article" article)
    (by @ArticleRemovedFromNewsRelatedWhitelist @"article" article)
