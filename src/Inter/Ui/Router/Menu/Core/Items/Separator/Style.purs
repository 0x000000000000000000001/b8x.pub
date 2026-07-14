module Inter.Ui.Router.Menu.Core.Items.Separator.Style where

import Proem hiding (div)

import CSS (backgroundColor, flexShrink, rgba, display, block)
import CSS as CSS
import DOM.HTML.Indexed (HTMLspan)
import Halogen.HTML (HTML, Node, span)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Layout (heightRem, margin2, widthPct100)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Items.Separator.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    display block
    widthPct100
    heightRem 0.09
    backgroundColor $ rgba 0 0 0 0.40
    flexShrink 0.0
    margin2 1.2 0.0

separator :: ∀ w i. Node HTMLspan w i
separator props = span ([ classes [ staticClass ] ] <> props)

separator_ :: ∀ w i. Array (HTML w i) -> HTML w i
separator_ = separator []