module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchMagazineIssuesProjectionWriteCopyState' = π :: Π "searchMagazineIssuesProjectionWriteCopyState"

type SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_STATE fx = (searchMagazineIssuesProjectionWriteCopyState :: State CopyOnWrite | fx)

type SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_PERSIST fx = (searchMagazineIssuesProjectionWriteCopyPersist :: ProjectionPersist | fx)
