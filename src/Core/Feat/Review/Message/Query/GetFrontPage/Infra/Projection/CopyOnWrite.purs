module Core.Feat.Review.Message.Query.GetFrontPage.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

getFrontPageProjectionWriteCopyState' = π :: Π "getFrontPageProjectionWriteCopyState"

type GET_FRONT_PAGE_PROJECTION_WRITE_COPY_STATE fx = (getFrontPageProjectionWriteCopyState :: State CopyOnWrite | fx)

type GET_FRONT_PAGE_PROJECTION_WRITE_COPY_PERSIST fx = (getFrontPageProjectionWriteCopyPersist :: ProjectionPersist | fx)
