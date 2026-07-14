module Inter.Ui.Router.PrettyBackground.Firefly.Style.Style where

import Proem hiding (div)

import CSS (backgroundColor, opacity, rgba, zIndex)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Effect (borderRadiusPct50, filter, mixBlendModeScreen, pointerEventsNone)
import Util.Style.Layout (heightRem, widthRem)
import Util.Style.Position (left0, positionFixed, top0)
import Util.Power (isPowerful)
import Util.Style.Selector ((.?))
import Util.Style.Transition (transitionNone)
import Util.Style.Typography (userSelectNone)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.PrettyBackground.Firefly.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

varXName :: String
varXName = "--firefly-x"

varYName :: String
varYName = "--firefly-y"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    widthRem 40.0
    heightRem 40.0
    backgroundColor $ rgba 255 255 255 0.56
    if isPowerful then
      filter "blur(9rem)"
    else
      filter "blur(3rem)"
    borderRadiusPct50
    positionFixed
    top0
    left0
    pointerEventsNone
    userSelectNone
    opacity 0.0
    zIndex (-1)
    transitionNone
    mixBlendModeScreen

firefly :: ∀ w i. Node HTMLdiv w i
firefly props = div ([ classes $ [ staticClass ] ] <> props)

firefly_ :: ∀ w i. Array (HTML w i) -> HTML w i
firefly_ = firefly []
