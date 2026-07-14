module Core.Feat.Review.Message.Query.GetArticle.Payload where

import Core.Mod.Article.Identifier.Message.Field (ArticleIdentifier, ArticleIdentifierField)
import Core.Feat.Review.Message.Query.GetArticle.Field.Needs (Needs, NeedsField)

type Payload =
  { identifier :: ArticleIdentifier
  , needs :: Needs
  }

type Fields =
  ( identifier :: ArticleIdentifierField
  , needs :: NeedsField
  )
