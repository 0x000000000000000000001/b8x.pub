module Inter.Ui.Router.Menu.Core.Items.Item.Style.Style where

import Proem hiding (div)

import CSS (black, color, flexShrink, hover, rgba)
import CSS as CSS
import CSS.Size (rem)
import CSS.Transform (transforms, translateX, scale)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Router.Menu.Core.Items.Item.Label.Style as Label
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Position (positionRelative)
import Util.Style.Layout (alignItemsCenter, justifyContentCenter, padding2, widthPct100)
import Util.Style.Typography (fontSizePct, userSelectNone)
import Util.Style.Effect (cursorPointer)
import Util.Style.Selector ((.?), (.*), (:&))
import Util.Style.Transition (transitions)
import Util.Style.Transition as Transition
import CSS.Transition (ease)
import CSS.Time (sec)
import Inter.Ui.Router.Style.Style (defaultTransitionTime)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Items.Item.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    color black
    justifyContentCenter
    alignItemsCenter
    cursorPointer
    padding2 0.2 0.0
    positionRelative
    fontSizePct 155.0
    widthPct100
    flexShrink 0.0
    userSelectNone
    transitions
      [ Transition.transform defaultTransitionTime ease (sec 0.0)
      , Transition.color defaultTransitionTime ease (sec 0.0)
      ]

    hover :& do
      color $ rgba 40 5 5 1.0
      transforms [ translateX $ rem 0.8, scale 1.02 1.02 ]

      Label.staticClass .* do
        widthPct100

item :: ∀ w i. Node HTMLdiv w i
item props = div ([ classes [ staticClass ] ] <> props)

item_ :: ∀ w i. Array (HTML w i) -> HTML w i
item_ = item []