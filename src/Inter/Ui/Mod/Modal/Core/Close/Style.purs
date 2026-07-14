module Inter.Ui.Mod.Modal.Core.Close.Style
  ( close
  , close_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (color, deg, hover, rotate, transforms, white)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import CSS as CSS
import CSS.Transform (scale)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (heightRem, padding1, widthRem)
import Util.Style.Typography (userSelectNone)
import Util.Style.Effect (cursorPointer, fill)
import Util.Style.Base (noCss)
import Util.Style.Selector (svg, (.?), (:&), (:*))
import Util.Style.Anchor (bottomLeftToTopRight)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Modal.Core.Close.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    color white
    bottomLeftToTopRight
    padding1 0.88
    cursorPointer
    userSelectNone

    svg :* do
      widthRem 3.0
      heightRem 3.0
      fill white

    hover :& do
      noCss

      svg :* do
        transforms [ rotate $ deg 90.0, scale 1.5 1.5 ]

close :: ∀ w i. Node HTMLdiv w i
close props = div ([ class_ staticClass ] <> props)

close_ :: ∀ w i. Array (HTML w i) -> HTML w i
close_ = close []