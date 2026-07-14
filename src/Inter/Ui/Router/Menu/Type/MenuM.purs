module Inter.Ui.Router.Menu.Type.MenuM where

import Halogen (HalogenM)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.Output (Output)

type MenuM a = HalogenM State Action Slots Output UiM a
