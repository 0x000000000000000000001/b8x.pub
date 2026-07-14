module Inter.Ui.Router.Menu.Core.TopSpacer.TopSpacer where

import Halogen.HTML (HTML)
import Inter.Ui.Router.Menu.Core.TopSpacer.Style as Style
import Inter.Ui.Router.Menu.Type.State.State (State)

topSpacer :: ∀ w i. State -> HTML w i
topSpacer state = Style.topSpacer_ state
