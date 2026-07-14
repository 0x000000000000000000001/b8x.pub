module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Result where

import Core.Message.Query.Result (Return)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Time.Instant (Instant)

type Result =
  { newsletters :: Array Newsletter
  , hasMore :: Boolean
  }

type Newsletter =
  { id :: Return NewsletterId
  , scheduledFor :: Return Instant
  , articles :: Return (Array ArticleId)
  }
