module Core.Feat.Reference.Message.Query.SearchEditors.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchEditorsProjectionWriteCopyState' = π :: Π "searchEditorsProjectionWriteCopyState"

type SEARCH_EDITORS_PROJECTION_WRITE_COPY_STATE fx = (searchEditorsProjectionWriteCopyState :: State CopyOnWrite | fx)

type SEARCH_EDITORS_PROJECTION_WRITE_COPY_PERSIST fx = (searchEditorsProjectionWriteCopyPersist :: ProjectionPersist | fx)
