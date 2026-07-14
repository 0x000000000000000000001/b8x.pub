module Core.Feat.Review.Message.Query.GetFrontPage.Payload where

import Core.Feat.Review.Message.Query.GetFrontPage.Field.Needs (Needs, NeedsField)
import Core.Mod.Article.FrontPage.Theme.Message.Field (ThemeField, Theme)

type Payload =
  { theme :: Theme
  , needs :: Needs
  }

type Fields =
  (theme :: ThemeField
  , needs :: NeedsField
  )
