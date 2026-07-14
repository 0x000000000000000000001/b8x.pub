module Core.Event.ArticleFeaturedOnFrontPage.Payload where

import Core.Mod.Article.FrontPage.Position.Position (Position)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Theme.Theme (Theme)
import Data.Maybe (Maybe)

type Payload =
  { article :: ArticleId
  , position :: Position
  , theme :: Maybe Theme
  }
