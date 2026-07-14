module Core.Feat.Sitemap.Projection.Index where

import Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Index (ListArticleYearsProjectionRow)
import Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Projection (LIST_ARTICLE_YEARS_PROJECTION_READ_FIND, LIST_ARTICLE_YEARS_PROJECTION_READ_SYNC_PROJECT, LIST_ARTICLE_YEARS_PROJECTION_WRITE_OPS)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Index (ListYearArticlesProjectionRow)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Projection (LIST_YEAR_ARTICLES_PROJECTION_READ_FIND, LIST_YEAR_ARTICLES_PROJECTION_READ_SYNC_PROJECT, LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Index (ListMagazineIssuesProjectionRow)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Projection (LIST_MAGAZINE_ISSUES_PROJECTION_READ_FIND, LIST_MAGAZINE_ISSUES_PROJECTION_READ_SYNC_PROJECT, LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS)
import Type.Row (type (+))

type SitemapProjectionRow r =
  ListArticleYearsProjectionRow
    ( ListYearArticlesProjectionRow
        ( ListMagazineIssuesProjectionRow r ) )

type SITEMAP_PROJECTION_WRITE_OPS fx =
  LIST_ARTICLE_YEARS_PROJECTION_WRITE_OPS
    + LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS
    + LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS
    + fx

type SITEMAP_PROJECTION_READ_FIND fx =
  LIST_ARTICLE_YEARS_PROJECTION_READ_FIND
    + LIST_YEAR_ARTICLES_PROJECTION_READ_FIND
    + LIST_MAGAZINE_ISSUES_PROJECTION_READ_FIND
    + fx

type SITEMAP_PROJECTION_READ_SYNC_PROJECT fx =
  LIST_ARTICLE_YEARS_PROJECTION_READ_SYNC_PROJECT
    + LIST_YEAR_ARTICLES_PROJECTION_READ_SYNC_PROJECT
    + LIST_MAGAZINE_ISSUES_PROJECTION_READ_SYNC_PROJECT
    + fx
