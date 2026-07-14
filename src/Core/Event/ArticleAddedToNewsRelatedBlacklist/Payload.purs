module Core.Event.ArticleAddedToNewsRelatedBlacklist.Payload where

import Core.Mod.Article.Id.Id (ArticleId)

type Payload =
  { article :: ArticleId
  }
