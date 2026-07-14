module Inter.Ui.Mod.LoginModal.State where

import Inter.Ui.Mod.LoginModal.Type (State, Input)

initialState :: Input -> State
initialState _ =
  { isOpen: false
  }
