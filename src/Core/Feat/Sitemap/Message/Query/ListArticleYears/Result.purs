module Core.Feat.Sitemap.Message.Query.ListArticleYears.Result where

import Core.Mod.Time.Instant (Instant)

type Result =
  { years :: Array { year :: Int, seo :: { updatedAt :: Instant } }
  }
