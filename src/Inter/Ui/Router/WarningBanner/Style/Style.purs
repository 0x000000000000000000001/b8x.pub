module Inter.Ui.Router.WarningBanner.Style.Style
  (fullModuleName
  , staticClass
  , staticStyle
  , warningBanner
  , warningBanner_
  ) where

import Proem hiding (div, top)

import CSS (backgroundColor, color, rgba)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (displayFlex, justifyContentCenter, padding4, widthPct100)
import Util.Style.Position (positionFixed, top0, left0)
import Util.Style.Selector ((.?))
import Util.Style.Typography (fontSizePct, textAlignCenter)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.WarningBanner.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionFixed
    top0
    left0
    widthPct100
    displayFlex
    justifyContentCenter
    padding4 0.5 1.0 0.5 1.0
    backgroundColor $ rgba 220 240 255 1.0
    color $ rgba 0 50 100 1.0
    fontSizePct 75.0
    textAlignCenter
    CSS.zIndex 999

warningBanner :: ∀ w i. Node HTMLdiv w i
warningBanner props = div ([ class_ staticClass ] <> props)

warningBanner_ :: ∀ w i. Array (HTML w i) -> HTML w i
warningBanner_ = warningBanner []
