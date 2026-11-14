module Inter.Ui.Page.Legal.State where

import Inter.Ui.Page.Legal.Type (State, Input)
import Data.Maybe (Maybe(..))

initialState :: Input -> State
initialState input = { isLoggedIn: input.context, pollForkId: Nothing }
