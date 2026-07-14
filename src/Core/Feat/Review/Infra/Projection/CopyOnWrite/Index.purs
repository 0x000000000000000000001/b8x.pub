module Core.Feat.Review.Infra.Projection.CopyOnWrite.Index where

import Proem

import Core.Feat.Review.Message.Query.GetArticle.Infra.Projection.CopyOnWrite (GET_ARTICLE_PROJECTION_WRITE_COPY_PERSIST, GET_ARTICLE_PROJECTION_WRITE_COPY_STATE, getArticleProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.GetArticleQuote.Infra.Projection.CopyOnWrite (GET_ARTICLE_QUOTE_PROJECTION_WRITE_COPY_PERSIST, GET_ARTICLE_QUOTE_PROJECTION_WRITE_COPY_STATE, getArticleQuoteProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.GetFrontPage.Infra.Projection.CopyOnWrite (GET_FRONT_PAGE_PROJECTION_WRITE_COPY_PERSIST, GET_FRONT_PAGE_PROJECTION_WRITE_COPY_STATE, getFrontPageProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.ListMostReadArticles.Infra.Projection.CopyOnWrite (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_COPY_PERSIST, LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_COPY_STATE, listMostReadArticlesProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Infra.Projection.CopyOnWrite (LIST_NEWS_RELATED_ARTICLES_PROJECTION_WRITE_COPY_PERSIST, LIST_NEWS_RELATED_ARTICLES_PROJECTION_WRITE_COPY_STATE, listNewsRelatedArticlesProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Infra.Projection.CopyOnWrite (LIST_NEWSLETTER_ARTICLES_PROJECTION_WRITE_COPY_PERSIST, LIST_NEWSLETTER_ARTICLES_PROJECTION_WRITE_COPY_STATE, listNewsletterArticlesProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Infra.Projection.CopyOnWrite (VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_COPY_PERSIST, VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_COPY_STATE, verifyNewsTopicLimitProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Infra.Projection.CopyOnWrite (VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyArticleLegacyIdUniquenessProjectionWriteCopyState')
import Core.Feat.Review.Message.Command.WriteArticle.Infra.Projection.CopyOnWrite as WriteArticle
import Core.Feat.Review.Message.Query.SearchArticles.Infra.Projection.CopyOnWrite (SEARCH_ARTICLES_PROJECTION_WRITE_COPY_PERSIST, SEARCH_ARTICLES_PROJECTION_WRITE_COPY_STATE, searchArticlesProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Infra.Projection.CopyOnWrite (VERIFY_ARTICLE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_ARTICLE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyArticleSlugUniquenessProjectionWriteCopyState')
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Infra.Projection.CopyOnWrite (VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_COPY_PERSIST, VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_COPY_STATE, verifyNewsRelatedArticleWhitelistLimitProjectionWriteCopyState')
import Data.Map as Map
import Run (Run)
import Run.State (evalStateAt)
import Type.Row (type (+))

evalProjectionWriteCopyState
  :: ∀ fx a
   . Run (REVIEW_PROJECTION_WRITE_COPY_STATE + fx) a
  -> Run fx a
evalProjectionWriteCopyState =
  evalStateAt getArticleProjectionWriteCopyState' Map.empty
    ▷ evalStateAt getArticleQuoteProjectionWriteCopyState' Map.empty
    ▷ evalStateAt getFrontPageProjectionWriteCopyState' Map.empty
    ▷ evalStateAt listMostReadArticlesProjectionWriteCopyState' Map.empty
    ▷ evalStateAt listNewsRelatedArticlesProjectionWriteCopyState' Map.empty
    ▷ evalStateAt listNewsletterArticlesProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyNewsTopicLimitProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyArticleLegacyIdUniquenessProjectionWriteCopyState' Map.empty
    ▷ evalStateAt searchArticlesProjectionWriteCopyState' Map.empty
    ▷ evalStateAt WriteArticle.writeArticleProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyArticleSlugUniquenessProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyNewsRelatedArticleWhitelistLimitProjectionWriteCopyState' Map.empty

type REVIEW_PROJECTION_WRITE_COPY_STATE fx =
  GET_ARTICLE_PROJECTION_WRITE_COPY_STATE
    + GET_ARTICLE_QUOTE_PROJECTION_WRITE_COPY_STATE
    + GET_FRONT_PAGE_PROJECTION_WRITE_COPY_STATE
    + LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_COPY_STATE
    + LIST_NEWS_RELATED_ARTICLES_PROJECTION_WRITE_COPY_STATE
    + LIST_NEWSLETTER_ARTICLES_PROJECTION_WRITE_COPY_STATE
    + VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_COPY_STATE
    + VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + SEARCH_ARTICLES_PROJECTION_WRITE_COPY_STATE
    + WriteArticle.WRITE_ARTICLE_PROJECTION_WRITE_COPY_STATE
    + VERIFY_ARTICLE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_COPY_STATE
    + fx

type REVIEW_PROJECTION_WRITE_COPY_PERSIST fx =
  GET_ARTICLE_PROJECTION_WRITE_COPY_PERSIST
    + GET_ARTICLE_QUOTE_PROJECTION_WRITE_COPY_PERSIST
    + GET_FRONT_PAGE_PROJECTION_WRITE_COPY_PERSIST
    + LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_COPY_PERSIST
    + LIST_NEWS_RELATED_ARTICLES_PROJECTION_WRITE_COPY_PERSIST
    + LIST_NEWSLETTER_ARTICLES_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + SEARCH_ARTICLES_PROJECTION_WRITE_COPY_PERSIST
    + WriteArticle.WRITE_ARTICLE_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_ARTICLE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_COPY_PERSIST
    + fx

type REVIEW_PROJECTION_WRITE_COPY fx =
  REVIEW_PROJECTION_WRITE_COPY_STATE
    + REVIEW_PROJECTION_WRITE_COPY_PERSIST
    + fx
