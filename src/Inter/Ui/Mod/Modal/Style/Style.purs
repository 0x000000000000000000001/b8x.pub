module Inter.Ui.Mod.Modal.Style.Style
  (class'
  , modal
  , modal_
  , staticClass
  , staticStyle
  , style
  , zIndex
  ) where

import Proem hiding (div, top)

import CSS (alignItems, backgroundColor, flexStart, rgba)
import CSS as CSS
import CSS.Overflow (overflow, overflowAuto)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Mod.Modal.Type (State)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Position (left0, positionFixed, top0)
import Util.Style.Layout (displayFlex, displayNone, heightPct, justifyContentCenter, widthPct100)
import Util.Style.Base (noCss)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Modal.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

zIndex :: Int
zIndex = 2000

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionFixed
    top0
    left0
    displayFlex
    justifyContentCenter
    alignItems flexStart
    widthPct100
    heightPct 100.0
    backgroundColor $ rgba 0 0 0 0.75
    CSS.zIndex zIndex
    overflow overflowAuto

style :: ∀ i. State i -> CSS.CSS
style { id, input: { open } } = do
  class' id .? do
    when open do
      noCss

    when (not open) do
      displayNone

modal :: ∀ w i. InstanceId -> Node HTMLdiv w i
modal id props = div ([ classes [ staticClass, class' id ] ] <> props)

modal_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
modal_ id = modal id []
