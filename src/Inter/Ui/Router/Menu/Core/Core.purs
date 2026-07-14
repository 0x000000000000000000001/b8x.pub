module Inter.Ui.Router.Menu.Core.Core where

import Proem hiding (top, div)

import Halogen (ComponentHTML, RefLabel(..))
import Halogen.HTML.Properties as Ref
import Inter.Ui.Router.Menu.Core.BottomSpacer.BottomSpacer (bottomSpacer)
import Inter.Ui.Router.Menu.Core.Items.Items (items)
import Inter.Ui.Router.Menu.Core.Search.Search (search)
import Inter.Ui.Router.Menu.Core.Style.Style as Style
import Inter.Ui.Router.Menu.Core.TopSpacer.TopSpacer (topSpacer)
import Inter.Ui.Router.Menu.Core.Newsletter.Newsletter (newsletter)
import Inter.Ui.Router.Menu.Core.Magazine.Magazine (magazine)
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Type.ControlledState as ControlledState
import Inter.Ui.UiM (UiM)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Core"

ref :: RefLabel
ref = RefLabel fullModuleName

core :: State -> ComponentHTML Action Slots UiM
core state =
  Style.core
    state
    [ Ref.ref ref
    ]
    ([ topSpacer state ]
        <> ( case state.activePanel of
               ControlledState.Controlled Newsletters -> newsletter state
               ControlledState.Uncontrolled Newsletters -> newsletter state
               ControlledState.Controlled Magazines -> magazine state
               ControlledState.Uncontrolled Magazines -> magazine state
               ControlledState.Controlled Search -> search state <> [ items state ]
               ControlledState.Uncontrolled Search -> search state <> [ items state ]
               ControlledState.Controlled None -> search state <> [ items state ]
               ControlledState.Uncontrolled None -> search state <> [ items state ]
           )
        <> [ bottomSpacer state ]
    )

