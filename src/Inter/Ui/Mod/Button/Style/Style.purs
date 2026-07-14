module Inter.Ui.Mod.Button.Style.Style where

import Proem hiding (top)

import CSS as CSS
import CSS.Color (white)
import CSS.Geometry (padding)
import CSS.Size (rem)
import CSS.Border (borderRadius, border, solid)
import CSS.Font (fontWeight, weight, fontSize)
import CSS.Cursor (cursor, pointer)
import CSS.Background (backgroundColor)
import Util.Style.Classname (generateStaticClass, refineClass')
import Util.Style.Selector ((.?), (:&))
import CSS.Pseudo (hover)
import Util.Style.Color (red)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Button.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

redClass :: String
redClass = refineClass' staticClass "red"

whiteTextClass :: String
whiteTextClass = refineClass' staticClass "white-text"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    padding (rem 0.75) (rem 1.5) (rem 0.75) (rem 1.5)
    borderRadius (rem 0.5) (rem 0.5) (rem 0.5) (rem 0.5)
    border solid (rem 0.0) white
    fontWeight (weight 600.0)
    fontSize (rem 1.1)
    cursor pointer
    CSS.key (CSS.fromString "transition") "all 0.2s ease-in-out"

    hover :& do
      CSS.key (CSS.fromString "transform") "translateY(-2px)"
      CSS.key (CSS.fromString "box-shadow") "0 4px 6px rgba(0,0,0,0.1)"

    (CSS.fromString ":disabled") :& do
      backgroundColor $ CSS.rgba 150 150 150 1.0
      CSS.color white
      CSS.key (CSS.fromString "transform") "none"
      CSS.key (CSS.fromString "box-shadow") "none"
      CSS.key (CSS.fromString "cursor") "not-allowed"

  redClass .? do
    backgroundColor red

  whiteTextClass .? do
    CSS.color white
