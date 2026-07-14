module Inter.Ui.Mod.Modal.Core.Style.Index
  (staticStyle
  ) where

import Proem (discard)

import CSS as CSS
import Inter.Ui.Mod.Modal.Core.Close.Style as Close
import Inter.Ui.Mod.Modal.Core.Style.Style as Core

staticStyle :: CSS.CSS
staticStyle = do
  Core.staticStyle
  Close.staticStyle
