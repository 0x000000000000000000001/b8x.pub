module Inter.Ui.Mod.Separator.Style.Index where

import Proem (discard)

import CSS as CSS
import Inter.Ui.Mod.Separator.Style.Style as Separator
import Inter.Ui.Mod.Separator.Text.Style as Text

staticStyle :: CSS.CSS
staticStyle = do
  Separator.staticStyle
  Text.staticStyle
