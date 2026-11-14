module Core.Event.ArticleTitleCorrected.Payload where

import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Title.Title (Title)

type Payload =
  { article :: ArticleId
  , title :: Title
  }
