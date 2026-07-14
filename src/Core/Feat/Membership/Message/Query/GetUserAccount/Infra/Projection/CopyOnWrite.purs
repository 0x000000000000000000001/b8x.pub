module Core.Feat.Membership.Message.Query.GetUserAccount.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

getUserAccountProjectionWriteCopyState' = π :: Π "getUserAccountProjectionWriteCopyState"

type GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_STATE fx = (getUserAccountProjectionWriteCopyState :: State CopyOnWrite | fx)

type GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_PERSIST fx = (getUserAccountProjectionWriteCopyPersist :: ProjectionPersist | fx)
