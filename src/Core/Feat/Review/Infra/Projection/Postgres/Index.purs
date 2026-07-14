module Core.Feat.Review.Infra.Projection.Postgres.Index where

import Proem

import Core.Feat.Review.Projection.Index (REVIEW_PROJECTION_WRITE_OPS)
import Core.Feat.Review.Infra.Projection.CopyOnWrite.Index (REVIEW_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Review.Message.Query.GetArticle.Projection.Projection (GetArticleProjection)
import Core.Feat.Review.Message.Query.GetArticleQuote.Projection.Projection (GetArticleQuoteProjection)
import Core.Feat.Review.Message.Query.GetFrontPage.Projection.Projection (GetFrontPageProjection)
import Core.Feat.Review.Message.Query.ListMostReadArticles.Projection.Projection (ListMostReadArticlesProjection)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Projection (ListNewsRelatedArticlesProjection)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Projection.Projection (ListNewsletterArticlesProjection)
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Projection.Projection (VerifyNewsTopicLimitProjection)
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Projection.Projection (VerifyArticleLegacyIdUniquenessProjection)
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection (SearchArticlesProjection)
import Core.Feat.Review.Message.Command.WriteArticle.Projection.Projection (WriteArticleProjection)
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Projection.Projection (VerifyArticleSlugUniquenessProjection)
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Projection.Projection (VerifyNewsRelatedArticleWhitelistLimitProjection)
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
onProjectionWriteOps =
  Base.onProjectionWriteOps @GetArticleProjection
    ◁ Base.onProjectionWriteOps @GetArticleQuoteProjection
    ◁ Base.onProjectionWriteOps @GetFrontPageProjection
    ◁ Base.onProjectionWriteOps @ListMostReadArticlesProjection
    ◁ Base.onProjectionWriteOps @ListNewsRelatedArticlesProjection
    ◁ Base.onProjectionWriteOps @ListNewsletterArticlesProjection
    ◁ Base.onProjectionWriteOps @VerifyNewsTopicLimitProjection
    ◁ Base.onProjectionWriteOps @VerifyArticleLegacyIdUniquenessProjection
    ◁ Base.onProjectionWriteOps @SearchArticlesProjection
    ◁ Base.onProjectionWriteOps @WriteArticleProjection
    ◁ Base.onProjectionWriteOps @VerifyArticleSlugUniquenessProjection
    ◁ Base.onProjectionWriteOps @VerifyNewsRelatedArticleWhitelistLimitProjection

onProjectionWriteCopyPersist
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteCopyPersist =
  Base.onProjectionWriteCopyPersist @GetArticleProjection
    ◁ Base.onProjectionWriteCopyPersist @GetArticleQuoteProjection
    ◁ Base.onProjectionWriteCopyPersist @GetFrontPageProjection
    ◁ Base.onProjectionWriteCopyPersist @ListMostReadArticlesProjection
    ◁ Base.onProjectionWriteCopyPersist @ListNewsRelatedArticlesProjection
    ◁ Base.onProjectionWriteCopyPersist @ListNewsletterArticlesProjection
    ◁ Base.onProjectionWriteCopyPersist @VerifyNewsTopicLimitProjection
    ◁ Base.onProjectionWriteCopyPersist @VerifyArticleLegacyIdUniquenessProjection
    ◁ Base.onProjectionWriteCopyPersist @SearchArticlesProjection
    ◁ Base.onProjectionWriteCopyPersist @WriteArticleProjection
    ◁ Base.onProjectionWriteCopyPersist @VerifyArticleSlugUniquenessProjection
    ◁ Base.onProjectionWriteCopyPersist @VerifyNewsRelatedArticleWhitelistLimitProjection

onProjectionReadSyncProject
  :: ∀ fx' a
   . RouterBuilder (REVIEW_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + REVIEW_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (REVIEW_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + REVIEW_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadSyncProject =
  Base.onProjectionReadSyncProject @GetArticleProjection
    ◁ Base.onProjectionReadSyncProject @GetArticleQuoteProjection
    ◁ Base.onProjectionReadSyncProject @GetFrontPageProjection
    ◁ Base.onProjectionReadSyncProject @ListMostReadArticlesProjection
    ◁ Base.onProjectionReadSyncProject @ListNewsRelatedArticlesProjection
    ◁ Base.onProjectionReadSyncProject @ListNewsletterArticlesProjection
    ◁ Base.onProjectionReadSyncProject @VerifyNewsTopicLimitProjection
    ◁ Base.onProjectionReadSyncProject @VerifyArticleLegacyIdUniquenessProjection
    ◁ Base.onProjectionReadSyncProject @SearchArticlesProjection
    ◁ Base.onProjectionReadSyncProject @WriteArticleProjection
    ◁ Base.onProjectionReadSyncProject @VerifyArticleSlugUniquenessProjection
    ◁ Base.onProjectionReadSyncProject @VerifyNewsRelatedArticleWhitelistLimitProjection

onProjectionReadSyncProjectWithNoop
  :: ∀ fx' a
   . RouterBuilder fx' a
  -> RouterBuilder fx' a
onProjectionReadSyncProjectWithNoop =
  Base.onProjectionReadSyncProjectWithNoop @GetArticleProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @GetArticleQuoteProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @GetFrontPageProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @ListMostReadArticlesProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @ListNewsRelatedArticlesProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @ListNewsletterArticlesProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyNewsTopicLimitProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyArticleLegacyIdUniquenessProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @SearchArticlesProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @WriteArticleProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyArticleSlugUniquenessProjection
    ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyNewsRelatedArticleWhitelistLimitProjection

