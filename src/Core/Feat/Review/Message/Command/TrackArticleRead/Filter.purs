module Core.Feat.Review.Message.Command.TrackArticleRead.Filter where

import Core.Event.Filter (Filter)
import Core.Feat.Review.Message.Command.TrackArticleRead.Payload (Payload)
import Core.Mod.Article.State as Article

filter :: Payload -> Filter
filter { id } = Article.filter id
