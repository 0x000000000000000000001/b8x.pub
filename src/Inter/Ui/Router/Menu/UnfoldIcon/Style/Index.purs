module Inter.Ui.Router.Menu.UnfoldIcon.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.UnfoldIcon.Dot.Style.Index as Dot
import Inter.Ui.Router.Menu.UnfoldIcon.Image.Style as Image
import Inter.Ui.Router.Menu.UnfoldIcon.Style.Style as UnfoldIcon

staticStyle :: CSS.CSS
staticStyle = do
  UnfoldIcon.staticStyle
  Image.staticStyle
  Dot.staticStyle

style :: State -> CSS.CSS
style s = do
  UnfoldIcon.style s
