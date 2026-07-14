module Inter.Ui.Mod.Tooltip.Outer.Style.Index
  (staticStyle
  ) where

import Proem (discard)

import Inter.Ui.Mod.Tooltip.Outer.Core.Style as Core
import Inter.Ui.Mod.Tooltip.Outer.Style.Style as Outer
import CSS as CSS

staticStyle :: CSS.CSS
staticStyle = do
  Core.staticStyle
  Outer.staticStyle
