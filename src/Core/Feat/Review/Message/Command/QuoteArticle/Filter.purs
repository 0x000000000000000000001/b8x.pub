module Core.Feat.Review.Message.Command.QuoteArticle.Filter where

import Proem hiding ((&&))

import Core.Event.Filter (Filter)
import Core.Feat.Review.Message.Command.QuoteArticle.Payload (Payload)
import Core.Mod.Article.State as Article

filter :: Payload -> Filter
filter { article } = Article.filter article
