module Inter.Ui.Mod.Input.Style.Style
  ( input
  , input_
  , staticClass
  , staticClassWhenOpen
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (position, relative, rem, transform, translate)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Mod.Input.Field.Style as Field
import Inter.Ui.Mod.Input.Label.Style as Label
import Inter.Ui.Mod.Input.Type.Theme (Theme(..))
import Inter.Ui.Mod.Input.Util.Style (colorBlue)
import Util.Style.Base (noCss)
import Util.Style.Classname (classes, generateStaticClass, refineClass')
import Util.Style.Effect (borderTopWidth, borderRightWidth, borderBottomWidth, borderLeftWidth)
import Util.Style.Layout (widthPct100)
import Util.Style.Position (top0)
import Util.Style.Selector ((.?), (.*))
import Util.Style.Typography (fontSizePct)

white :: CSS.Color
white = CSS.rgba 255 255 255 1.0

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Input.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticClassWhenOpen :: String
staticClassWhenOpen = refineClass' staticClass "open"

themeClass :: Theme -> String
themeClass Default = ""
themeClass LightOutlined = "theme-light-outlined"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    position relative
    widthPct100

  staticClassWhenOpen .? do
    noCss

    Label.staticClass .* do
      top0
      transform $ translate (rem 0.8) (rem 0.6)
      fontSizePct 70.0
      colorBlue

  (CSS.fromString ".theme-light-outlined") .? do
    Label.staticClass .* do
      CSS.color white
    Field.staticClass .* do
      CSS.backgroundColor $ CSS.rgba 0 0 0 0.5
      CSS.borderColor white
      borderTopWidth 0.1
      borderRightWidth 0.1
      borderBottomWidth 0.1
      borderLeftWidth 0.1

  (CSS.fromString ".theme-light-outlined.open") .? do
    Label.staticClass .* do
      CSS.color white

input :: ∀ w i. Theme -> Boolean -> Node HTMLdiv w i
input theme open props = div ([ classes [ staticClass, open ? staticClassWhenOpen ↔ "", themeClass theme ] ] <> props)

input_ :: ∀ w i. Theme -> Boolean -> Array (HTML w i) -> HTML w i
input_ theme open = input theme open []
