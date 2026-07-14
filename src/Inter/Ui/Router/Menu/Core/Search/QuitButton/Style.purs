module Inter.Ui.Router.Menu.Core.Search.QuitButton.Style where

import Proem hiding (top, div)

import CSS (CSS)
import CSS.Time (sec)
import CSS.Transition (ease)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, div)
import Halogen.HTML.Properties (IProp)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Style.Style (defaultTransitionTime)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Effect (cursorPointer)
import Util.Style.Typography (userSelectNone)
import Util.Style.Layout (marginBottom, visibilityHidden)
import Util.Style.Selector ((.?))
import Util.Style.Transition (transitions)
import Util.Style.Transition as Transition

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.QuitButton.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    cursorPointer
    userSelectNone
    marginBottom 0.0
    visibilityHidden
    transitions
      [ Transition.height defaultTransitionTime ease (sec 0.0)
      , Transition.marginBottom defaultTransitionTime ease (sec 0.0)
      , Transition.visibility (sec 0.0) ease (sec 0.0)
      ]

quitButton :: ∀ w i. State -> Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
quitButton { id } props = div ([ classes [ staticClass, class' id ] ] <> props)

quitButton_ :: ∀ w i. State -> Array (HTML w i) -> HTML w i
quitButton_ state = quitButton state []
