module Core.Feat.Sitemap.Infra.Projection.Postgres.Index where

import Proem

import Core.Feat.Sitemap.Projection.Index (SITEMAP_PROJECTION_WRITE_OPS)
import Core.Feat.Sitemap.Infra.Projection.CopyOnWrite.Index (SITEMAP_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Projection (ListArticleYearsProjection)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Projection (ListYearArticlesProjection)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Projection (ListMagazineIssuesProjection)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (PROJECTION_WRITE_COPY_STATE)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT)
import Infra.Projection.Postgres.Projection as Base
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionWriteOps
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteOps = Base.onProjectionWriteOps @ListArticleYearsProjection
  ◁ Base.onProjectionWriteOps @ListYearArticlesProjection
  ◁ Base.onProjectionWriteOps @ListMagazineIssuesProjection

onProjectionWriteCopyPersist
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteCopyPersist = Base.onProjectionWriteCopyPersist @ListArticleYearsProjection
  ◁ Base.onProjectionWriteCopyPersist @ListYearArticlesProjection
  ◁ Base.onProjectionWriteCopyPersist @ListMagazineIssuesProjection

onProjectionReadSyncProject
  :: ∀ fx' a
   . RouterBuilder (SITEMAP_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + SITEMAP_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (SITEMAP_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + SITEMAP_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadSyncProject = Base.onProjectionReadSyncProject @ListArticleYearsProjection
  ◁ Base.onProjectionReadSyncProject @ListYearArticlesProjection
  ◁ Base.onProjectionReadSyncProject @ListMagazineIssuesProjection

onProjectionReadSyncProjectWithNoop
  :: ∀ fx' a
   . RouterBuilder fx' a
  -> RouterBuilder fx' a
onProjectionReadSyncProjectWithNoop = Base.onProjectionReadSyncProjectWithNoop @ListArticleYearsProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @ListYearArticlesProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @ListMagazineIssuesProjection
