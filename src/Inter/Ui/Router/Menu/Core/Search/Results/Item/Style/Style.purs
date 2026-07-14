module Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Style where

import Proem hiding (top, div)

import CSS (CSS, alignItems, background, flexShrink, flexStart, hover, position, relative, rgba)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Transform (transformTranslateRem)
import Util.Style.Layout (displayFlex, marginBottom, overflowHidden, padding2, widthPct100)
import Util.Style.Effect (borderRadiusRem1, boxShadow, cursorPointer)
import Util.Style.Selector ((.?), (:&))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    displayFlex
    alignItems flexStart
    padding2 1.0 1.2
    marginBottom 1.0
    cursorPointer
    background $ rgba 255 255 255 0.8
    borderRadiusRem1 0.6
    boxShadow 0.0 0.2 0.6 $ rgba 0 0 0 0.04
    position relative
    flexShrink 0.0
    overflowHidden
    widthPct100

    hover :& do
      background $ rgba 255 255 255 0.95
      boxShadow 0.0 0.4 1.2 $ rgba 0 0 0 0.08
      transformTranslateRem 0.0 (-0.1)

item :: ∀ w i. InstanceId -> Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
item id props = div ([ classes [ staticClass, class' id ] ] <> props)

item_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
item_ id = item id []
