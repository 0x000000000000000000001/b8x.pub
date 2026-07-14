module Inter.Ui.Router.Menu.Style.Index where

import Proem (discard)

import CSS as CSS
import Halogen.HTML (HTML)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Router.Menu.Core.Style.Index as Core
import Inter.Ui.Router.Menu.Style.Style as Menu
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.UnfoldIcon.Style.Index as UnfoldIcon

staticStyle :: CSS.CSS
staticStyle = do
  Core.staticStyle
  Menu.staticStyle
  UnfoldIcon.staticStyle

sheet :: ∀ w i. State -> HTML w i
sheet s = stylesheet do
  UnfoldIcon.style s
