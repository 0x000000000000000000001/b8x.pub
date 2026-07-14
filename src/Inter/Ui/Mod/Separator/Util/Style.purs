module Inter.Ui.Mod.Separator.Util.Style
  (grey
  ) where

import Proem hiding (top)

import CSS (darken)
import Color (Color)
import Util.Style.Color (lightGrey)

grey :: Color
grey = darken 0.1 lightGrey