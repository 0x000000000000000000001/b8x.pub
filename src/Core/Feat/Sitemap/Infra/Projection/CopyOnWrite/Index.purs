module Core.Feat.Sitemap.Infra.Projection.CopyOnWrite.Index where

import Proem

import Core.Feat.Sitemap.Message.Query.ListArticleYears.Infra.Projection.CopyOnWrite (LIST_ARTICLE_YEARS_PROJECTION_WRITE_COPY_PERSIST, LIST_ARTICLE_YEARS_PROJECTION_WRITE_COPY_STATE, listArticleYearsProjectionWriteCopyState')
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Infra.Projection.CopyOnWrite (LIST_YEAR_ARTICLES_PROJECTION_WRITE_COPY_PERSIST, LIST_YEAR_ARTICLES_PROJECTION_WRITE_COPY_STATE, listYearArticlesProjectionWriteCopyState')
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Infra.Projection.CopyOnWrite (LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_PERSIST, LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_STATE, listMagazineIssuesProjectionWriteCopyState')
import Data.Map as Map
import Run (Run)
import Run.State (evalStateAt)
import Type.Row (type (+))

evalProjectionWriteCopyState
  :: ∀ fx a
   . Run (SITEMAP_PROJECTION_WRITE_COPY_STATE + fx) a
  -> Run fx a
evalProjectionWriteCopyState =
  evalStateAt listArticleYearsProjectionWriteCopyState' Map.empty
    ▷ evalStateAt listYearArticlesProjectionWriteCopyState' Map.empty
    ▷ evalStateAt listMagazineIssuesProjectionWriteCopyState' Map.empty

type SITEMAP_PROJECTION_WRITE_COPY_STATE fx =
  LIST_ARTICLE_YEARS_PROJECTION_WRITE_COPY_STATE
    + LIST_YEAR_ARTICLES_PROJECTION_WRITE_COPY_STATE
    + LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_STATE
    + fx

type SITEMAP_PROJECTION_WRITE_COPY_PERSIST fx =
  LIST_ARTICLE_YEARS_PROJECTION_WRITE_COPY_PERSIST
    + LIST_YEAR_ARTICLES_PROJECTION_WRITE_COPY_PERSIST
    + LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_PERSIST
    + fx

type SITEMAP_PROJECTION_WRITE_COPY fx =
  SITEMAP_PROJECTION_WRITE_COPY_STATE
    + SITEMAP_PROJECTION_WRITE_COPY_PERSIST
    + fx
