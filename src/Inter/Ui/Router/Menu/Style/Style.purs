module Inter.Ui.Router.Menu.Style.Style where

import Proem hiding (top, div)

import CSS (height, vh)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Position (left0, positionFixed, top0)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

zIndex :: Int
zIndex = 1000

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionFixed
    top0
    left0
    height (vh 100.0)
    CSS.zIndex zIndex

menu :: ∀ w i. Node HTMLdiv w i
menu props = div ([ classes [ staticClass ] ] <> props)

menu_ :: ∀ w i. Array (HTML w i) -> HTML w i
menu_ = menu []
