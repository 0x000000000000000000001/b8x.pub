module Inter.Ui.Mod.LoginModal.HandleAction.Index (handleAction) where

import Proem

import Halogen (modify_)
import Inter.Ui.Mod.LoginModal.Type (Action(..), LoginModalM)
import Inter.Ui.Mod.LoginModal.HandleAction.Initialize (initialize)

handleAction :: Action -> LoginModalM Ɩ
handleAction = case _ of
  Initialize -> initialize
  Receive input -> do
    modify_ \st -> st { isOpen = if input.context then false else st.isOpen }
  HandleModalOutput _ -> do
    modify_ _ { isOpen = false }
