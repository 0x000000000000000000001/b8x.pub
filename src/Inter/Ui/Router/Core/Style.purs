module Inter.Ui.Router.Core.Style
  (core
  , core_
  , staticClass
  , staticStyle
  , zIndex
  ) where

import Proem hiding (top)

import CSS as CSS
import DOM.HTML.Indexed (HTMLmain)
import Halogen.HTML (HTML, Node, main)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Position (positionRelative)
import Util.Style.Layout (displayFlex, flexGrow1)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Core.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

zIndex :: Int
zIndex = 990

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayFlex
    flexGrow1
    positionRelative
    CSS.zIndex zIndex

core :: ∀ w i. Node HTMLmain w i
core props = main ([ class_ staticClass ] <> props)

core_ :: ∀ w i. Array (HTML w i) -> HTML w i
core_ = core []
