module Inter.Ui.Router.Menu.Core.Search.QuitButton.QuitButton where

import Proem

import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Halogen.HTML.Events (onClick)
import Inter.Ui.Router.Menu.Core.Search.QuitButton.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action(CloseSearch))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)

quitButton :: State -> ComponentHTML Action Slots UiM
quitButton state =
  Style.quitButton state
    [ onClick $ κ CloseSearch
    ]
    [ text "← Quitter la recherche et revenir au menu" ]
