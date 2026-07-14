module Inter.Ui.Router.Footer.Style.Style
  (fullModuleName
  , staticClass
  , staticStyle
  , footer
  , footer_
  ) where

import Proem hiding (div, top)

import CSS as CSS
import CSS (hover)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Color as Color
import Util.Style.Layout (alignItemsCenter, displayFlex, gapRem, heightRem, justifyContentCenter, paddingTop, widthPct100, widthRem)
import Util.Style.Effect (cursorPointer, fill)
import Util.Style.Position (positionRelative)
import Util.Style.Selector (svg, (.?), (:*), (:&))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Footer.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    paddingTop 2.0
    widthPct100
    heightRem 10.0
    displayFlex
    justifyContentCenter
    alignItemsCenter
    gapRem 2.0
    positionRelative

    svg :* do
      widthRem 2.0
      heightRem 2.0
      fill Color.red
      cursorPointer

      hover :& do
        fill Color.textRed

footer :: ∀ w i. Node HTMLdiv w i
footer props = div ([ class_ staticClass ] <> props)

footer_ :: ∀ w i. Array (HTML w i) -> HTML w i
footer_ = footer []
