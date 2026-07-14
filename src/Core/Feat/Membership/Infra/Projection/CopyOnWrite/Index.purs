module Core.Feat.Membership.Infra.Projection.CopyOnWrite.Index where

import Core.Feat.Membership.Message.Query.GetUserAccount.Infra.Projection.CopyOnWrite (GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_PERSIST, GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_STATE, getUserAccountProjectionWriteCopyState')
import Data.Map as Map
import Run (Run)
import Run.State (evalStateAt)
import Type.Row (type (+))

evalProjectionWriteCopyState
  :: ∀ fx a
   . Run (MEMBERSHIP_PROJECTION_WRITE_COPY_STATE + fx) a
  -> Run fx a
evalProjectionWriteCopyState =
  evalStateAt getUserAccountProjectionWriteCopyState' Map.empty

type MEMBERSHIP_PROJECTION_WRITE_COPY_STATE fx =
  GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_STATE
    + fx

type MEMBERSHIP_PROJECTION_WRITE_COPY_PERSIST fx =
  GET_USER_ACCOUNT_PROJECTION_WRITE_COPY_PERSIST
    + fx

type MEMBERSHIP_PROJECTION_WRITE_COPY fx =
  MEMBERSHIP_PROJECTION_WRITE_COPY_STATE
    + MEMBERSHIP_PROJECTION_WRITE_COPY_PERSIST
    + fx
