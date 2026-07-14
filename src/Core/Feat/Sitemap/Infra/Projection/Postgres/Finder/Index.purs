module Core.Feat.Sitemap.Infra.Projection.Postgres.Finder.Index where

import Proem

import Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Projection as ListArticleYears
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Projection as ListYearArticles
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Projection as ListMagazineIssues
import Core.Mod.Projection.Index (PROJECTION_READ_SYNC_PROJECT)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT)
import Infra.Projection.Postgres.Finder.Finder as Base
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionReadFind
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadFind = Base.onProjectionReadFind @ListArticleYears.ArticleYear
  ◁ Base.onProjectionReadFind @ListYearArticles.Article
  ◁ Base.onProjectionReadFind @ListMagazineIssues.MagazineIssue
