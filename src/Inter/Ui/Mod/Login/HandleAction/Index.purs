module Inter.Ui.Mod.Login.HandleAction.Index (handleAction) where

import Inter.Ui.Mod.Login.Type (Action(..), LoginM)
import Inter.Ui.Mod.Login.HandleAction.Submit (submit)
import Inter.Ui.Mod.Login.HandleAction.HandleEmailInput (handleEmailInput)
import Proem

handleAction :: Action -> LoginM Ɩ
handleAction = case _ of
  Initialize -> pure unit
  HandleEmailInput out -> handleEmailInput out
  Submit event -> submit event
