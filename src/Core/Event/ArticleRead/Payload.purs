module Core.Event.ArticleRead.Payload where

import Core.Mod.Article.Id.Id (ArticleId)

type Payload =
  { id :: ArticleId
  }
