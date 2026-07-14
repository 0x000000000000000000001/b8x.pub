module Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Infra.Projection.CopyOnWrite where

import Proem
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyNewsRelatedArticleWhitelistLimitProjectionWriteCopyState' = π :: Π "verifyNewsRelatedArticleWhitelistLimitProjectionWriteCopyState"

type VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_COPY_STATE fx
  = ( verifyNewsRelatedArticleWhitelistLimitProjectionWriteCopyState :: State CopyOnWrite | fx )

type VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_COPY_PERSIST fx
  = ( verifyNewsRelatedArticleWhitelistLimitProjectionWriteCopyPersist :: ProjectionPersist | fx )
