module Inter.Ui.Router.Header.Style.Style
  (header
  , header_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (top, div)

import CSS (column, flexDirection)
import CSS as CSS
import DOM.HTML.Indexed (HTMLheader)
import Halogen.HTML (HTML, Node)
import Halogen.HTML as Halogen
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (alignItemsCenter, displayFlex, widthPct100)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Header.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    widthPct100
    displayFlex
    flexDirection column
    alignItemsCenter

header :: ∀ w i. Node HTMLheader w i
header props = Halogen.header ([ class_ staticClass ] <> props)

header_ :: ∀ w i. Array (HTML w i) -> HTML w i
header_ = header []
