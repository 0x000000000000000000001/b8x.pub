module Core.Feat.Reference.Message.Query.GetAuthor.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

getAuthorProjectionWriteCopyState' = π :: Π "getAuthorProjectionWriteCopyState"

type GET_AUTHOR_PROJECTION_WRITE_COPY_STATE fx = (getAuthorProjectionWriteCopyState :: State CopyOnWrite | fx)

type GET_AUTHOR_PROJECTION_WRITE_COPY_PERSIST fx = (getAuthorProjectionWriteCopyPersist :: ProjectionPersist | fx)
