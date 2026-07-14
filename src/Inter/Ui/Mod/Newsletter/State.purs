module Inter.Ui.Mod.Newsletter.State where

import Inter.Ui.Mod.Newsletter.Type (Input, State, Status(..))

initialState :: Input -> State
initialState _ =
  { email: ""
  , status: Idle
  }
