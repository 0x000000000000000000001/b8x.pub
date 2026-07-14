module Inter.Ui.Page.Donate.State where

import Inter.Ui.Page.Donate.Type (State, Input)
import Data.Maybe (Maybe(..))

initialState :: Input -> State
initialState input = { isLoggedIn: input.context, pollForkId: Nothing }
