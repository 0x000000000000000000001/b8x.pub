module Inter.Ui.Router.Menu.Core.Newsletter.BackButton.BackButton where

import Proem

import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Halogen.HTML.Events (onClick)
import Inter.Ui.Router.Menu.Core.Search.QuitButton.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)

backButton :: State -> Action -> String -> ComponentHTML Action Slots UiM
backButton state action label =
  Style.quitButton state
    [ onClick $ κ action
    ]
    [ text label ]
