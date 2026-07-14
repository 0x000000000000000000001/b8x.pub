module Inter.Ui.Router.Menu.Core.Search.Search where

import Proem hiding (div)

import Halogen.HTML (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Search.Input.Input (input)
import Inter.Ui.Router.Menu.Core.Search.QuitButton.QuitButton (quitButton)
import Inter.Ui.Router.Menu.Core.Search.Results.Results (results)
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.UiM (UiM)



search :: State -> Array (ComponentHTML Action Slots UiM)
search s =
  [ quitButton s
  , input s
  ] <> results s
