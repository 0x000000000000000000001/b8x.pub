module Inter.Ui.Router.Menu.Core.CloseButton.Style
  ( closeButton
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)
import CSS (CSS, position, absolute, right, top, zIndex)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Effect (cursorPointer)
import Util.Style.MediaQuery (onTabletLte)
import Util.Style.Layout (displayFlex, displayNone, justifyContentCenter, alignItemsCenter, widthRem, heightRem)
import Util.Style.Selector ((.?), (:*), svg)
import CSS.Size (rem)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.CloseButton.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    position absolute
    top (rem 1.6)
    right (rem 2.4)
    widthRem 3.2
    heightRem 3.2
    cursorPointer
    justifyContentCenter
    alignItemsCenter
    zIndex 1000
    displayNone

    onTabletLte do
      displayFlex
      top (rem 0.8)
      right (rem 0.8)
      widthRem 2.4
      heightRem 2.4
      svg :* do
        widthRem 2.4
        heightRem 2.4

    svg :* do
      widthRem 3.2
      heightRem 3.2

closeButton :: ∀ w i. Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
closeButton props = div ([ classes [ staticClass ] ] <> props)
