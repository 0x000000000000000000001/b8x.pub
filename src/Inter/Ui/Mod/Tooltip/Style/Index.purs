module Inter.Ui.Mod.Tooltip.Style.Index where

import Proem (discard)

import CSS as CSS
import Inter.Ui.Mod.Tooltip.Inner.Style as Inner
import Inter.Ui.Mod.Tooltip.Outer.Style.Index as Outer
import Inter.Ui.Mod.Tooltip.Style.Style as Tooltip

staticStyle :: CSS.CSS
staticStyle = do
  Tooltip.staticStyle
  Inner.staticStyle
  Outer.staticStyle
