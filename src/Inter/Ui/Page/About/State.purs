module Inter.Ui.Page.About.State where

import Inter.Ui.Page.About.Type (State, Input)
import Data.Maybe (Maybe(..))

initialState :: Input -> State
initialState input = { isLoggedIn: input.context, pollForkId: Nothing }
