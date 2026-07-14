module Core.Feat.Review.Message.Query.SearchArticles.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchArticlesProjectionWriteCopyState' = π :: Π "searchArticlesProjectionWriteCopyState"

type SEARCH_ARTICLES_PROJECTION_WRITE_COPY_STATE fx
  = ( searchArticlesProjectionWriteCopyState :: State CopyOnWrite | fx )

type SEARCH_ARTICLES_PROJECTION_WRITE_COPY_PERSIST fx
  = ( searchArticlesProjectionWriteCopyPersist :: ProjectionPersist | fx )
