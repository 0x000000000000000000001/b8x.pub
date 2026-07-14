module Inter.Ui.Router.Menu.Render (render) where

import Proem hiding (top, div)

import Halogen (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Core (core)
import Inter.Ui.Router.Menu.Style.Index (sheet)
import Inter.Ui.Router.Menu.Style.Style (menu_)
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.UnfoldIcon.UnfoldIcon (unfoldIcon)
import Inter.Ui.UiM (UiM)

render :: State -> ComponentHTML Action Slots UiM
render s =
  menu_
    [ sheet s
    , unfoldIcon s
    , core s
    ]
