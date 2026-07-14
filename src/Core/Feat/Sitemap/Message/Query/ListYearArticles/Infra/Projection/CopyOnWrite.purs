module Core.Feat.Sitemap.Message.Query.ListYearArticles.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

listYearArticlesProjectionWriteCopyState' :: Π "listYearArticlesProjectionWriteCopyState"
listYearArticlesProjectionWriteCopyState' = π :: Π "listYearArticlesProjectionWriteCopyState"

type LIST_YEAR_ARTICLES_PROJECTION_WRITE_COPY_STATE fx = (listYearArticlesProjectionWriteCopyState :: State CopyOnWrite | fx)
type LIST_YEAR_ARTICLES_PROJECTION_WRITE_COPY_PERSIST fx = (listYearArticlesProjectionWriteCopyPersist :: ProjectionPersist | fx)
