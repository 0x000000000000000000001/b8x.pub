module Inter.Ui.Router.Menu.UnfoldIcon.UnfoldIcon where

import Proem hiding (top, div)

import Halogen (ComponentHTML)
import Halogen.HTML.Events (onMouseOver)
import Inter.Ui.Router.Menu.Type.Action (Action(Open))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.UnfoldIcon.Image.Image as Image
import Inter.Ui.Router.Menu.UnfoldIcon.Style.Style as Style
import Inter.Ui.UiM (UiM)
import Data.Maybe (isJust)
import Inter.Ui.Router.Menu.UnfoldIcon.Dot.Style.Style as Dot

unfoldIcon :: State -> ComponentHTML Action Slots UiM
unfoldIcon state =
  Style.unfoldIcon state
    [ onMouseOver $ κ Open ]
    ( [ Image.image state ]
        <> (if isJust state.me then [ Dot.dot_ [] ] else [])
    )
