module Core.Feat.Review.Message.Query.GetArticleQuote.Payload where

import Core.Feat.Review.Message.Query.GetArticleQuote.Field.Needs (Needs, NeedsField)
import Core.Mod.Article.Theme.Message.Field.MaybeTheme (Theme, ThemeField)

type Payload =
  { needs :: Needs
  -- | If Nothing, the query does NOT filter by theme (it returns quotes from articles with any theme, or no theme).
  -- | It does NOT mean "filter articles that have no theme".
  , theme :: Theme
  }

type Fields =
  ( needs :: NeedsField
  , theme :: ThemeField
  )
