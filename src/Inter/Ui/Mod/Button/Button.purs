module Inter.Ui.Mod.Button.Button (button) where

import Proem hiding (div)

import Halogen.HTML as H
import DOM.HTML.Indexed (HTMLbutton)
import Util.Style.Classname (classes)
import Inter.Ui.Mod.Button.Type (Input)
import Inter.Ui.Mod.Button.Style.Style (staticClass, redClass, whiteTextClass)

button :: ∀ w i. Input -> Array (H.IProp HTMLbutton i) -> Array (H.HTML w i) -> H.HTML w i
button { bgClass, fgClass } props children =
  let
    bg = if bgClass == "red" then redClass else ""
    fg = if fgClass == "white" then whiteTextClass else ""
  in
    H.button ([ classes [ staticClass, bg, fg ] ] <> props) children
