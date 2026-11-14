module Core.Feat.Review.Message.Query.SearchNewsTopics.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchNewsTopicsProjectionWriteCopyState' = π :: Π "searchNewsTopicsProjectionWriteCopyState"

type SEARCH_NEWS_TOPICS_PROJECTION_WRITE_COPY_STATE fx = (searchNewsTopicsProjectionWriteCopyState :: State CopyOnWrite | fx)

type SEARCH_NEWS_TOPICS_PROJECTION_WRITE_COPY_PERSIST fx = (searchNewsTopicsProjectionWriteCopyPersist :: ProjectionPersist | fx)
