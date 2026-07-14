module Inter.Ui.Router.Menu.UnfoldIcon.Image.Style where

import Proem

import CSS (CSS)
import DOM.HTML.Indexed (HTMLimg)
import Halogen.HTML (HTML, Leaf, img)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Effect (filter)
import Util.Style.Layout (widthPct100)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.UnfoldIcon.Image.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    widthPct100
    filter "invert(18%) sepia(91%) saturate(5412%) hue-rotate(341deg) brightness(87%) contrast(95%)"

image :: ∀ w i. State -> Leaf HTMLimg w i
image { id } props = img ([ classes [ staticClass, class' id ] ] <> props)

image_ :: ∀ w i. State -> HTML w i
image_ state = image state []
