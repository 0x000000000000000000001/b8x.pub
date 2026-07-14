module Inter.Ui.Mod.Login.HandleAction.HandleEmailInput (handleEmailInput) where

import Proem

import Halogen (modify_)
import Inter.Ui.Mod.Input.Type.Output as Input
import Inter.Ui.Mod.Login.Type (LoginM)

handleEmailInput :: Input.Output -> LoginM Ɩ
handleEmailInput = case _ of
  Input.ValueChanged value -> modify_ \st ->
    if st.email == value then st
    else st { email = value, invalidEmail = false }
  _ -> pure unit
