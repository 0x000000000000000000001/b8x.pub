module Inter.Ui.Router.Menu.UnfoldIcon.Style.Style where

import Proem hiding (div, top)

import CSS (backgroundColor, borderColor, left, opacity, rem, rgba, solid, top, transforms)
import CSS as CSS
import CSS.Transform (scale, translateX)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Router.Menu.Style.Style as Core
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Type.ControlledState as ControlledState
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Effect (backdropFilter, borderRadiusPct50, borderStyle, borderWidth1, boxShadow, cursorPointer)
import Util.Style.Layout (alignItemsCenter, displayFlex, justifyContentCenter, padding1, widthRem)
import Util.Style.Position (positionAbsolute)
import Util.Power (isPowerful)
import Util.Style.Selector ((.?))
import Util.Style.Typography (userSelectNone)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.UnfoldIcon.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionAbsolute
    widthRem 5.0
    padding1 1.0
    borderRadiusPct50
    if isPowerful then do
      backgroundColor $ rgba 255 255 255 0.6
      backdropFilter "blur(1rem)"
    else do
      backgroundColor $ rgba 255 255 255 0.95
    boxShadow 0.0 0.2 0.6 $ rgba 0 0 0 0.15
    borderStyle solid
    borderWidth1 0.05
    borderColor $ rgba 255 255 255 0.4
    CSS.zIndex $ Core.zIndex + 1
    cursorPointer
    displayFlex
    alignItemsCenter
    justifyContentCenter
    userSelectNone

style :: State -> CSS.CSS
style { id, open } = do
  class' id .? do
    let
      isOpen = case open of
        ControlledState.Controlled o -> o
        ControlledState.Uncontrolled o -> o
      s = isOpen ? 0.0 ↔ 1.0

    transforms [ translateX $ isOpen ? rem (-1.4) ↔ rem 0.0, scale s s ]

    opacity $ isOpen ? 0.0 ↔ 1.0

    top $ rem $ isOpen ? 0.0 ↔ 2.8
    left $ rem $ isOpen ? 0.0 ↔ 2.8

unfoldIcon :: ∀ w i. State -> Node HTMLdiv w i
unfoldIcon { id } props children = div ([ classes [ staticClass, class' id ] ] <> props) children

unfoldIcon_ :: ∀ w i. State -> Array (HTML w i) -> HTML w i
unfoldIcon_ state children = unfoldIcon state [] children
