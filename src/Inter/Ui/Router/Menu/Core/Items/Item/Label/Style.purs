module Inter.Ui.Router.Menu.Core.Items.Item.Label.Style where

import Proem hiding (top, div)

import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Layout (flexGrow1, overflowHidden, widthRem)
import Util.Style.Effect (cursorPointer)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Items.Item.Label.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    flexGrow1
    widthRem 30.0
    overflowHidden
    cursorPointer

label :: ∀ w i. Node HTMLdiv w i
label props = div ([ classes [ staticClass ] ] <> props)

label_ :: ∀ w i. Array (HTML w i) -> HTML w i
label_ = label []
