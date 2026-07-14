module Inter.Ui.Router.Menu.Core.Search.Results.Style.Style where

import Proem hiding (div)

import CSS (CSS, column, ease, flexDirection, height, opacity, sec, vh)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, div)
import Halogen.HTML.Properties (IProp)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Router.Style.Style (defaultTransitionTime)
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Layout (displayFlex, heightRem, overflowScroll, visibilityHidden, visibilityVisible, widthPct100)
import Util.Style.Selector ((.?))
import Util.Style.Transition (transitions)
import Util.Style.Transition as Transition

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticClassWhenSearchIsOpen :: String
staticClassWhenSearchIsOpen = refineClass' staticClass "searchIsOpen"

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    widthPct100
    displayFlex
    flexDirection column
    heightRem 0.0
    visibilityHidden
    opacity 0.0
    overflowScroll
    transitions
      [ Transition.height defaultTransitionTime ease (sec 0.0)
      , Transition.opacity (sec 0.0) ease (sec 0.0)
      , Transition.visibility (sec 0.0) ease (sec 0.0)
      ]

  staticClassWhenSearchIsOpen .? do
    height $ vh 100.0
    visibilityVisible
    opacity 1.0
    transitions
      [ Transition.height defaultTransitionTime ease (sec 0.0)
      , Transition.opacity defaultTransitionTime ease (sec 0.0)
      , Transition.visibility (sec 0.0) ease (sec 0.0)
      ]

results :: ∀ w i. State -> Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
results { id, activePanel } props =
  let
    activePanel' = case activePanel of
      Controlled a -> a
      Uncontrolled a -> a
    open = activePanel' == Search
  in
    div
      ([ classes
            $ [ staticClass, class' id ]
            <> (open ? [ staticClassWhenSearchIsOpen ] ↔ [])
        ]
          <> props
      )

results_ :: ∀ w i. State -> Array (HTML w i) -> HTML w i
results_ state = results state []
