module Inter.Ui.Mod.Tooltip.Inner.Style
  (inner
  , inner_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Base (noCss)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Tooltip.Inner.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    noCss

inner :: ∀ w i. Node HTMLdiv w i
inner props = div ([ class_ staticClass ] <> props)

inner_ :: ∀ w i. Array (HTML w i) -> HTML w i
inner_ = inner []