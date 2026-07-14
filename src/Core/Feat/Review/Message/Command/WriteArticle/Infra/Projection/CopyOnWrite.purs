module Core.Feat.Review.Message.Command.WriteArticle.Infra.Projection.CopyOnWrite where

import Proem
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

writeArticleProjectionWriteCopyState' = π :: Π "writeArticleProjectionWriteCopyState"

type WRITE_ARTICLE_PROJECTION_WRITE_COPY_STATE fx
  = ( writeArticleProjectionWriteCopyState :: State CopyOnWrite | fx )

type WRITE_ARTICLE_PROJECTION_WRITE_COPY_PERSIST fx
  = ( writeArticleProjectionWriteCopyPersist :: ProjectionPersist | fx )
