module Inter.Ui.Mod.Input.Util.Style where

import CSS (backgroundColor, color, rgba)
import CSS as CSS
import CSS.Color (Color)
import Color (darken)

blue :: Color
blue = rgba 102 175 233 0.9

textBlue :: Color
textBlue = darken 0.4 blue

colorBlue :: CSS.CSS
colorBlue = color textBlue

backgroundColorBlue :: CSS.CSS
backgroundColorBlue = backgroundColor blue
