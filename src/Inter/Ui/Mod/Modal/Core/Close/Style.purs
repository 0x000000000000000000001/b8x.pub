module Inter.Ui.Mod.Modal.Core.Close.Style
  ( close
  , close_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (color, deg, hover, right, rotate, top, transforms, white, zIndex)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import CSS as CSS
import CSS.Size (rem)
import CSS.Transform (scale)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (displayFlex, alignItemsCenter, justifyContentCenter, heightRem, widthRem)
import Util.Style.Typography (userSelectNone)
import Util.Style.Effect (cursorPointer, fill)
import Util.Style.Position (positionFixed)
import Util.Style.Base (noCss)
import Util.Style.Selector (svg, (.?), (:&), (:*))
import Util.Style.MediaQuery (onTabletLte)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Modal.Core.Close.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    color white
    positionFixed
    top (rem 1.6)
    right (rem 2.4)
    widthRem 3.2
    heightRem 3.2
    displayFlex
    justifyContentCenter
    alignItemsCenter
    zIndex 2001
    cursorPointer
    userSelectNone

    onTabletLte do
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
      fill white

    hover :& do
      noCss

      svg :* do
        transforms [ rotate $ deg 90.0, scale 1.5 1.5 ]

close :: ∀ w i. Node HTMLdiv w i
close props = div ([ class_ staticClass ] <> props)

close_ :: ∀ w i. Array (HTML w i) -> HTML w i
close_ = close []