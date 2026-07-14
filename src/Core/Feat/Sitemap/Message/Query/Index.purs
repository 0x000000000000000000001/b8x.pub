module Core.Feat.Sitemap.Message.Query.Index where

import Core.Feat.Sitemap.Message.Query.ListArticleYears.Query (ListArticleYears)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Query (ListYearArticles)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Query (ListMagazineIssues)

type SitemapQueryRow r =
  ( listArticleYears :: ListArticleYears
  , listYearArticles :: ListYearArticles
  , listMagazineIssues :: ListMagazineIssues
  | r
  )

