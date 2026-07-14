module Core.Feat.Reference.Message.Query.SearchAuthors.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchAuthorsProjectionWriteCopyState' = π :: Π "searchAuthorsProjectionWriteCopyState"

type SEARCH_AUTHORS_PROJECTION_WRITE_COPY_STATE fx = (searchAuthorsProjectionWriteCopyState :: State CopyOnWrite | fx)

type SEARCH_AUTHORS_PROJECTION_WRITE_COPY_PERSIST fx = (searchAuthorsProjectionWriteCopyPersist :: ProjectionPersist | fx)
