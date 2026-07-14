module Core.Event.NewsletterScheduled.Payload where

import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Time.Instant (Instant)

type Payload =
  { id :: NewsletterId
  , scheduledFor :: Instant
  , articles :: Array ArticleId
  }
