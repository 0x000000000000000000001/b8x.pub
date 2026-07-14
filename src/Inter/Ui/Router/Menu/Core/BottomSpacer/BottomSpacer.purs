module Inter.Ui.Router.Menu.Core.BottomSpacer.BottomSpacer where

import Halogen.HTML (HTML)
import Inter.Ui.Router.Menu.Core.BottomSpacer.Style as Style
import Inter.Ui.Router.Menu.Type.State.State (State)

bottomSpacer :: ∀ w i. State -> HTML w i
bottomSpacer state = Style.bottomSpacer_ state
