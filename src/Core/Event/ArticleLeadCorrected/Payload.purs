module Core.Event.ArticleLeadCorrected.Payload where

import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Lead.Lead (Lead)

type Payload =
  { article :: ArticleId
  , lead :: Lead
  }
