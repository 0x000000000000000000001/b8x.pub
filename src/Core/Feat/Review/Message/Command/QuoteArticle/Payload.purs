module Core.Feat.Review.Message.Command.QuoteArticle.Payload where

import Core.Mod.Article.Id.Message.Field.Article (Article, ArticleField)
import Core.Feat.Review.Message.Command.QuoteArticle.Field.Quote (Quote, QuoteField)

type Payload =
  { article :: Article
  , quote :: Quote
  }

type Fields =
  ( article :: ArticleField
  , quote :: QuoteField
  )
