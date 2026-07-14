module Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

listNewsRelatedArticlesProjectionWriteCopyState' = π :: Π "listNewsRelatedArticlesProjectionWriteCopyState"

type LIST_NEWS_RELATED_ARTICLES_PROJECTION_WRITE_COPY_STATE fx = (listNewsRelatedArticlesProjectionWriteCopyState :: State CopyOnWrite | fx)

type LIST_NEWS_RELATED_ARTICLES_PROJECTION_WRITE_COPY_PERSIST fx = (listNewsRelatedArticlesProjectionWriteCopyPersist :: ProjectionPersist | fx)
