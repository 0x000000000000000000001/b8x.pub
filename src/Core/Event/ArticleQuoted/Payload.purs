module Core.Event.ArticleQuoted.Payload where

import Core.Mod.Article.Id.Id (ArticleId)

type Payload =
  { article :: ArticleId
  , quote :: String
  }
