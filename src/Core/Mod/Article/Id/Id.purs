module Core.Mod.Article.Id.Id
  (ArticleId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.Article.Article (Article)

type ArticleId = Id.Id Article
