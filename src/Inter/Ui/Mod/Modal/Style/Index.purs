module Inter.Ui.Mod.Modal.Style.Index where

import Proem (discard)

import CSS as CSS
import Halogen.HTML (HTML)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Mod.Modal.Core.Style.Index as Core
import Inter.Ui.Mod.Modal.Style.Style as Modal
import Inter.Ui.Mod.Modal.Type (State)

staticStyle :: CSS.CSS
staticStyle = do
  Core.staticStyle
  Modal.staticStyle

sheet :: ∀ input w i. State input -> HTML w i
sheet s = stylesheet do
  Modal.style s
