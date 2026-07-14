module Inter.Ui.Page.Home.FrontPage.Column.Style
  (column
  , column_
  , staticClass
  , staticClassWhenCentral
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (flexDirection)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass, refineClass')
import Util.Style.Layout (displayFlex, gapRem)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Home.FrontPage.Column.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticClassWhenCentral :: String
staticClassWhenCentral = refineClass' staticClass "central"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayFlex
    flexDirection CSS.column
    gapRem 2.0

column :: ∀ w i. Boolean -> Node HTMLdiv w i
column central props = div ([ classes [ staticClass, central ? staticClassWhenCentral ↔ "" ] ] <> props)

column_ :: ∀ w i. Boolean -> Array (HTML w i) -> HTML w i
column_ central = column central []
