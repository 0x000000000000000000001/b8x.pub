module Inter.Ui.Router.Menu.UnfoldIcon.Dot.Style.Style where

import Proem hiding (div)

import CSS (backgroundColor, border, px, rgba, solid)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Effect (borderRadiusPct50, boxShadow)
import Util.Style.Layout (heightRem, widthRem)
import Util.Style.Position (positionAbsolute, rightRem, topRem)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.UnfoldIcon.Dot.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionAbsolute
    topRem 0.2
    rightRem 0.2
    widthRem 1.0
    heightRem 1.0
    borderRadiusPct50
    backgroundColor $ rgba 34 197 94 1.0
    border solid (px 2.0) (rgba 255 255 255 1.0)
    boxShadow 0.0 0.1 0.2 (rgba 0 0 0 0.2)

dot :: ∀ w i. Node HTMLdiv w i
dot props children = div ([ classes [ staticClass ] ] <> props) children

dot_ :: ∀ w i. Array (HTML w i) -> HTML w i
dot_ children = dot [] children
