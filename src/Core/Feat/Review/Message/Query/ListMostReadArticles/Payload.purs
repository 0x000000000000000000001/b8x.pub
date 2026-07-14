module Core.Feat.Review.Message.Query.ListMostReadArticles.Payload where

import Core.Feat.Review.Message.Query.ListMostReadArticles.Field.Needs (Needs, NeedsField)
import Core.Mod.Article.Theme.Message.Field.MaybeTheme (Theme, ThemeField)
import Core.Feat.Review.Message.Query.ListMostReadArticles.Field.Blacklist (Blacklist, BlacklistField)

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
