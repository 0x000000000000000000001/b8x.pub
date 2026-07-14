module Inter.Ui.Mod.Login.State (initialState) where

import Inter.Ui.Mod.Login.Type (Input, State)

initialState :: Input -> State
initialState _ =
  { email: ""
  , submitted: false
  , loading: false
  , invalidEmail: false
  }
