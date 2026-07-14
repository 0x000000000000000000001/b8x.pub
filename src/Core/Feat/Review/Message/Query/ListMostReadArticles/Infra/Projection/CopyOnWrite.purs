module Core.Feat.Review.Message.Query.ListMostReadArticles.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

listMostReadArticlesProjectionWriteCopyState' = π :: Π "listMostReadArticlesProjectionWriteCopyState"

type LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_COPY_STATE fx = (listMostReadArticlesProjectionWriteCopyState :: State CopyOnWrite | fx)

type LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_COPY_PERSIST fx = (listMostReadArticlesProjectionWriteCopyPersist :: ProjectionPersist | fx)
