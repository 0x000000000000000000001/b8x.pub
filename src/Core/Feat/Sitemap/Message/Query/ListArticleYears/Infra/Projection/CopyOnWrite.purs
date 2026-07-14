module Core.Feat.Sitemap.Message.Query.ListArticleYears.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

listArticleYearsProjectionWriteCopyState' :: Π "listArticleYearsProjectionWriteCopyState"
listArticleYearsProjectionWriteCopyState' = π :: Π "listArticleYearsProjectionWriteCopyState"

type LIST_ARTICLE_YEARS_PROJECTION_WRITE_COPY_STATE fx = (listArticleYearsProjectionWriteCopyState :: State CopyOnWrite | fx)
type LIST_ARTICLE_YEARS_PROJECTION_WRITE_COPY_PERSIST fx = (listArticleYearsProjectionWriteCopyPersist :: ProjectionPersist | fx)
