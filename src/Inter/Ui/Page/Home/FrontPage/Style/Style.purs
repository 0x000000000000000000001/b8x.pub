module Inter.Ui.Page.Home.FrontPage.Style.Style
  (frontPage
  , frontPage_
  , staticClass
  , staticStyle
  , zIndex
  ) where

import Proem hiding (div, top)

import CSS (alignItems, display, flexStart, grid)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (gapRem, gridTemplateColumns, maxWidthRem, widthPct100)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Home.FrontPage.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

zIndex :: Int
zIndex = 990

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    display grid
    maxWidthRem 90.0
    gridTemplateColumns "1fr 2fr 1fr"
    gapRem 2.0
    widthPct100
    alignItems flexStart

frontPage :: ∀ w i. Node HTMLdiv w i
frontPage props = div ([ class_ staticClass ] <> props)

frontPage_ :: ∀ w i. Array (HTML w i) -> HTML w i
frontPage_ = frontPage []
