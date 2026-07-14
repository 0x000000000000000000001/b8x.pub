module Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Payload where

import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Field.Needs (Needs, NeedsField)
import Core.Mod.Article.Theme.Message.Field.MaybeTheme (Theme, ThemeField)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Field.Blacklist (Blacklist, BlacklistField)

type Fields =
  ( theme :: ThemeField
  , blacklist :: BlacklistField
  , needs :: NeedsField
  )

type Payload =
  { theme :: Theme
  , blacklist :: Blacklist
  , needs :: Needs
  }
