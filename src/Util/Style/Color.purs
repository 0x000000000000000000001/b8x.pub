module Util.Style.Color where

import Proem hiding (bottom, top)
import CSS (CSS) as CSS
import CSS (backgroundColor, color, rgba)
import CSS.Color (Color, hsl)
import Color (darken)

red :: Color
red = hsl 353.91 0.8174 0.4725

textRed :: Color
textRed = darken 0.1 red

colorRed :: CSS.CSS
colorRed = color textRed

lightGrey :: Color
lightGrey = hsl 0.0 0.0 0.9

backgroundWhite :: Color
backgroundWhite = hsl 196.0 1.0 0.98

limegreen :: Color
limegreen = hsl 120.0 0.61 0.49

backgroundColorRed :: CSS.CSS
backgroundColorRed = backgroundColor red

backgroundColorWhite :: CSS.CSS
backgroundColorWhite = backgroundColor backgroundWhite

backgroundColorTransparent :: CSS.CSS
backgroundColorTransparent = backgroundColor transparent

transparent :: Color
transparent = rgba 0 0 0 0.0
