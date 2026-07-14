module Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Result where

import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Mod.Time.Instant (Instant)

type Result =
  { magazineIssues :: Array
      { id :: MagazineIssueId
      , number :: Int
      , slug :: Slug
      , seo :: { updatedAt :: Instant }
      }
  }
