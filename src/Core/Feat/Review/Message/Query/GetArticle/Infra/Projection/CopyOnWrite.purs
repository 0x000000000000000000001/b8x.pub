module Core.Feat.Review.Message.Query.GetArticle.Infra.Projection.CopyOnWrite where

import Proem
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

getArticleProjectionWriteCopyState' = π :: Π "getArticleProjectionWriteCopyState"

type GET_ARTICLE_PROJECTION_WRITE_COPY_STATE fx
  = ( getArticleProjectionWriteCopyState :: State CopyOnWrite | fx )

type GET_ARTICLE_PROJECTION_WRITE_COPY_PERSIST fx
  = ( getArticleProjectionWriteCopyPersist :: ProjectionPersist | fx )
