module Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Payload where

import Core.Mod.Article.FrontPage.Position.Message.Field (Position, PositionField)
import Core.Mod.Article.FrontPage.Theme.Message.Field (ThemeField, Theme)
import Core.Mod.Article.Id.Message.Field.Article (Article, ArticleField)

type Payload =
  { article :: Article
  , position :: Position
  , theme :: Theme
  }

type Fields =
  (article :: ArticleField
  , position :: PositionField
  , theme :: ThemeField
  )
