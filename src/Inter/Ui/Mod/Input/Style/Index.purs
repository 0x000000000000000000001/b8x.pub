module Inter.Ui.Mod.Input.Style.Index where

import Proem (discard)

import CSS as CSS
import Halogen.HTML (HTML)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Mod.Input.Field.Style as Field
import Inter.Ui.Mod.Input.Label.Style as Label
import Inter.Ui.Mod.Input.Style.Style as Input
import Inter.Ui.Mod.Input.Type.State (State)

staticStyle :: CSS.CSS
staticStyle = do
  Field.staticStyle
  Input.staticStyle
  Label.staticStyle

sheet :: ∀ w i. State -> HTML w i
sheet s = stylesheet do
  Field.style s

rootStaticClass :: String
rootStaticClass = Input.staticClass
