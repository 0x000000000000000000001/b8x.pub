module Core.Event.ArticleContentCorrected.Payload where

import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Id.Id (ArticleId)

type Payload =
  { article :: ArticleId
  , content :: Content
  }
