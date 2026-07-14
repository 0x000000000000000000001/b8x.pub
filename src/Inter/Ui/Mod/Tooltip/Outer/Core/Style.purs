module Inter.Ui.Mod.Tooltip.Outer.Core.Style
  ( core
  , core_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (backgroundColor, color, rgba, white)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import CSS as CSS
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (overflowHidden, padding1, widthPct100)
import Util.Style.Effect (borderRadiusRem1)
import Util.Style.Selector ((.?))
import Util.Style.Typography (fontSizeRem, textShadowNone)
import Util.Style.Base (raw)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Tooltip.Outer.Core.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    backgroundColor $ rgba 0 0 0 0.9
    color white
    padding1 1.0
    borderRadiusRem1 0.3
    overflowHidden
    widthPct100
    fontSizeRem 1.0
    raw "font-weight" "normal"
    textShadowNone

core :: ∀ w i. Node HTMLdiv w i
core props = div ([ class_ staticClass ] <> props)

core_ :: ∀ w i. Array (HTML w i) -> HTML w i
core_ = core []
