module Inter.Ui.Mod.Tooltip.Outer.Style.Style
  (outer
  , outer_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (zIndex)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import CSS as CSS
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Position (positionRelative)
import Util.Style.Selector ((.?))
import Util.Style.Anchor (centerLeftToCenterRight)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Tooltip.Outer.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionRelative
    centerLeftToCenterRight
    zIndex 1000

outer :: ∀ w i. Node HTMLdiv w i
outer props = div ([ class_ staticClass ] <> props)

outer_ :: ∀ w i. Array (HTML w i) -> HTML w i
outer_ = outer []
