module Inter.Ui.Router.Menu.Core.TopSpacer.Style where

import Proem hiding (div)

import CSS (CSS, flexGrow)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, div)
import Halogen.HTML.Properties (IProp)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Router.Menu.Type.State.State as Menu
import Inter.Ui.Type.InstanceId (InstanceId)
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Layout (height0, widthPct100)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.TopSpacer.Style"

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
    flexGrow 1.0

  staticClassWhenSearchIsOpen .? do
    height0
    flexGrow 0.0

topSpacer :: ∀ w i. Menu.State -> Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
topSpacer { id, activePanel } props =
  let
    activePanel' = case activePanel of
      Controlled a -> a
      Uncontrolled a -> a
  in
    div
      ([ classes
            $ [ staticClass, class' id ]
            <> ((activePanel' /= None) ? [ staticClassWhenSearchIsOpen ] ↔ [])
        ] <> props
      )

topSpacer_ :: ∀ w i. Menu.State -> HTML w i
topSpacer_ state = topSpacer state [] []
