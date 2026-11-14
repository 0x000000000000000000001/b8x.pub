module Inter.Ui.Page.Newsletter.Style where

import Proem hiding (div)

import CSS (CSS, marginLeft, marginRight)
import CSS.Common (auto)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.ContainerQuery (containerTypeInlineSize)
import Util.Style.Layout (maxWidthRem, padding1, widthPct100)
import Util.Style.MediaQuery (onMobileLte)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Newsletter.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

pageMaxWidth :: Number
pageMaxWidth = 90.0

pagePadding :: Number
pagePadding = 2.0

mobilePagePadding :: Number
mobilePagePadding = 1.0

staticStyle :: CSS
staticStyle = staticClass .? do
  widthPct100
  maxWidthRem pageMaxWidth
  marginLeft auto
  marginRight auto
  padding1 pagePadding
  containerTypeInlineSize

  onMobileLte do
    padding1 mobilePagePadding

newsletter :: ∀ w i. Node HTMLdiv w i
newsletter props = div ([ class_ staticClass ] <> props)

newsletter_ :: ∀ w i. Array (HTML w i) -> HTML w i
newsletter_ = newsletter []
