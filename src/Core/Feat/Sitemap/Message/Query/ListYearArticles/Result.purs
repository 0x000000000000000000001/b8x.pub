module Core.Feat.Sitemap.Message.Query.ListYearArticles.Result where

import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Time.Instant (Instant)

type Result =
  { articles :: Array
      { id :: ArticleId
      , slug :: Slug
      , year :: Int
      , seo :: { updatedAt :: Instant }
      }
  }
