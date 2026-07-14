module Inter.Ui.Router.Menu.Core.Newsletter.Style.Style where

import Proem hiding (div)

import CSS (CSS, marginBottom, rem, fontSize)
import Halogen.HTML (HTML, div)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Layout (overflowXHidden, overflowYAuto, widthPct100, flexGrow1)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Newsletter.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

itemsClass :: String
itemsClass = refineClass' staticClass "items"

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  itemsClass .? do
    widthPct100
    flexGrow1
    overflowXHidden
    overflowYAuto

  ".newsletter-day-title" .? do
    fontSize (rem 1.4)

  ".newsletter-day-articles" .? do
    marginBottom (rem 2.5)

items_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
items_ id = div [ classes [ itemsClass, class' id ] ]
