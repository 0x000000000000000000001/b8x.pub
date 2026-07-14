module Inter.Ui.Mod.Input.Label.Style
  (label
  , label_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (cursor, pct, rem, rgba, transform, translate)
import CSS as CSS
import Color (cssStringRGBA)
import Util.Style.Base (raw_)
import CSS.Cursor (text)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Position (left0, positionAbsolute, topPct50)
import Util.Style.Typography (userSelectNone)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Input.Label.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionAbsolute
    topPct50
    left0
    transform $ translate (rem 0.8) (pct $ -50.0)
    cursor text
    userSelectNone
    raw_ "color" (cssStringRGBA $ rgba 0 0 0 0.5)

label :: ∀ w i. Node HTMLdiv w i
label props = div ([ class_ staticClass ] <> props)

label_ :: ∀ w i. Array (HTML w i) -> HTML w i
label_ = label []