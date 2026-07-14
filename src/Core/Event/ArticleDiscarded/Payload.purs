module Core.Event.ArticleDiscarded.Payload where

import Core.Mod.Article.Id.Id (ArticleId)

type Payload =
  { article :: ArticleId
  }
