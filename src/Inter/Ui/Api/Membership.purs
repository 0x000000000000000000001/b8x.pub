module Inter.Ui.Api.Membership where

import Proem

import Core.Feat.Membership.Message.Query.GetUserAccount.Query (GetUserAccount(..))
import Core.Feat.Membership.Message.Query.GetUserAccount.Payload as GetUserAccountPayload
import Core.Feat.Membership.Message.Query.GetUserAccount.Result as GetUserAccountResult
import Inter.Ui.Remote (query)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Type.Remote (Remote)

import Control.Monad.Reader.Trans (runReaderT)

apiGetUserAccount
  :: GetUserAccountPayload.Payload
  -> UiM (Remote GetUserAccountResult.Result)
apiGetUserAccount p = runReaderT (query (GetUserAccount p)) unit
