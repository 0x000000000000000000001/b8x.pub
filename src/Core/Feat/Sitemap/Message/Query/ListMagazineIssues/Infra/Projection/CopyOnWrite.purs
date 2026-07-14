module Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

listMagazineIssuesProjectionWriteCopyState' :: Π "listMagazineIssuesProjectionWriteCopyState"
listMagazineIssuesProjectionWriteCopyState' = π :: Π "listMagazineIssuesProjectionWriteCopyState"

type LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_STATE fx = (listMagazineIssuesProjectionWriteCopyState :: State CopyOnWrite | fx)
type LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_PERSIST fx = (listMagazineIssuesProjectionWriteCopyPersist :: ProjectionPersist | fx)
