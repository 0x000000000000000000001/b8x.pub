module Inter.Ui.Page.Donate.HandleAction.Index where

import Proem

import Inter.Ui.Page.Donate.Type (Action(..), DonateM)
import Inter.Ui.Capability.Modal.Trans (openLoginModal)
import Halogen (modify_, fork, kill, get, lift)
import Data.Maybe (Maybe(..))
import Effect.Aff (delay, Milliseconds(..))
import Control.Monad.Rec.Class (Step(..), tailRecM)
import Inter.Ui.Api.Membership (apiGetUserAccount)
import Core.Mod.User.Id.Message.Field.TargetUser (TargetUser(..))
import Core.Feat.Membership.Message.Query.GetUserAccount.Field.Needs (Needs(..))
import Core.Message.Query.Payload (Need(..))
import Inter.Ui.Capability.Store.Trans (updateStore)
import Inter.Ui.Store.Store as GlobalStore
import Core.Message.Query.Result as QueryResult
import Network.RemoteData (RemoteData(..))

handleAction :: Action -> DonateM Unit
handleAction = case _ of
  Receive input -> modify_ _ { isLoggedIn = input.context }
  OpenLoginModal -> openLoginModal
  Initialize -> do
    fid <- fork $ tailRecM pollLoop ι
    modify_ _ { pollForkId = Just fid }
  Finalize -> do
    st <- get
    case st.pollForkId of
      Just fid -> kill fid
      Nothing -> η ι

pollLoop :: Ɩ -> DonateM (Step Ɩ Ɩ)
pollLoop _ = do
  ʌ' $ delay $ Milliseconds 1000.0
  st <- get
  if st.isLoggedIn then do
    let payload = { user: Me, needs: Needs { adFree: Needed ι ι, hasPaidLastYear: Needed ι ι } }
    res <- lift $ apiGetUserAccount payload
    case res of
      Success { adFree: QueryResult.Given adFree, hasPaidLastYear: QueryResult.Given hasPaidLastYear } -> do
        updateStore $ GlobalStore.SetMembershipStatus { adFree, hasPaidLastYear }
        if adFree then η $ Done ι else η $ Loop ι
      _ -> η $ Loop ι
  else η $ Loop ι
