module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchNewslettersProjectionWriteCopyState' = π :: Π "searchNewslettersProjectionWriteCopyState"

type SEARCH_NEWSLETTERS_PROJECTION_WRITE_COPY_STATE fx = (searchNewslettersProjectionWriteCopyState :: State CopyOnWrite | fx)

type SEARCH_NEWSLETTERS_PROJECTION_WRITE_COPY_PERSIST fx = (searchNewslettersProjectionWriteCopyPersist :: ProjectionPersist | fx)
