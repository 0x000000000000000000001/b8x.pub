module Inter.Ui.Router.Menu.Core.Search.Input.Style where

import Proem hiding (top, div)

import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Inter.Ui.Mod.Input.Style.Index as Input
import Util.Style.Classname (classes, generateStaticClass, refineClass')
import Util.Style.Layout (marginBottom, widthPct100)
import Util.Style.Typography (fontSizePct)
import Util.Style.Selector ((.?), (.*), (¨&))
import Util.Style.Transition (transitionNone)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Type.ControlledState (ControlledState(..))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Input.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticClassWhenSearchIsOpen :: String
staticClassWhenSearchIsOpen = refineClass' staticClass "searchIsOpen"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    transitionNone
    widthPct100
    marginBottom 2.0
    CSS.display CSS.flex
    CSS.key (CSS.fromString "flex-shrink") "0"
    CSS.key (CSS.fromString "align-items") "center"
    CSS.backgroundColor (CSS.rgba 255 255 255 0.55)
    CSS.border CSS.solid (CSS.rem 0.15) (CSS.rgba 0 0 0 0.2)
    CSS.borderRadius (CSS.rem 0.2) (CSS.rem 0.2) (CSS.rem 0.2) (CSS.rem 0.2)

    ":focus-within" ¨& do
      CSS.borderColor (CSS.rgba 0 50 150 1.0) -- Blue focus ring

    Input.rootStaticClass .* do
      transitionNone
      widthPct100
      CSS.flexGrow 1.0
      CSS.key (CSS.fromString "min-width") "0px"
      fontSizePct 130.0

input :: ∀ w i. State -> Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
input { activePanel } props =
  let
    activePanel' = case activePanel of
      Controlled a -> a
      Uncontrolled a -> a
    open = activePanel' == Search
  in
    div ([ classes $ [ staticClass ] <> (open ? [ staticClassWhenSearchIsOpen ] ↔ []) ] <> props)

input_ :: ∀ w i. State -> Array (HTML w i) -> HTML w i
input_ state = input state []
