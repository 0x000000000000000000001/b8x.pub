module Inter.Ui.Mod.Login.HandleAction.Submit (submit) where

import Proem

import Halogen (modify_, get, lift)
import Inter.Ui.Mod.Login.Type (LoginM)
import Inter.Ui.Api.Auth (requestMagicLink)
import Core.Mod.Email.Email as Email
import Data.Either (Either(..))

import Web.Event.Event (Event, preventDefault)
import Effect.Class (liftEffect)

submit :: Event -> LoginM Ɩ
submit event = do
  liftEffect $ preventDefault event
  state <- get
  if state.loading || state.email == "" then pure unit
  else case Email.make_ true state.email of
    Left _ -> modify_ \st -> st { invalidEmail = true }
    Right _ -> do
      modify_ \st -> st { loading = true, invalidEmail = false }
      success <- lift $ requestMagicLink state.email
      modify_ \st -> st { loading = false, submitted = success }
