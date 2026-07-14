module Core.Feat.Review.Message.Command.DiscardArticle.Payload where

import Core.Mod.Article.Id.Message.Field.Article (Article, ArticleField)

type Payload =
  { article :: Article
  }

type Fields =
  (article :: ArticleField
  )
