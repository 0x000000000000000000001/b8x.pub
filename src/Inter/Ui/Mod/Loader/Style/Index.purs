module Inter.Ui.Mod.Loader.Style.Index where

import Proem (discard)

import CSS (Color)
import CSS as CSS
import Halogen.HTML (HTML)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Mod.Loader.Animation.Style as Animation
import Inter.Ui.Mod.Loader.Style.Style as Loader

staticStyle :: CSS.CSS
staticStyle = do
  Animation.staticStyle
  Loader.staticStyle

sheet :: ∀ w i. Color -> HTML w i
sheet color = stylesheet do
  Animation.style color
