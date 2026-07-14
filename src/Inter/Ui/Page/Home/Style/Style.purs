module Inter.Ui.Page.Home.Style.Style
  ( fullModuleName
  , home
  , home_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (flexDirection, column)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (alignItemsCenter, displayFlex, justifyContentCenter, padding4, widthPct100)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Home.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    widthPct100
    displayFlex
    flexDirection column
    alignItemsCenter
    justifyContentCenter
    padding4 2.1 2.0 1.0 2.0

home :: ∀ w i. Node HTMLdiv w i
home props = div ([ class_ staticClass ] <> props)

home_ :: ∀ w i. Array (HTML w i) -> HTML w i
home_ = home []
