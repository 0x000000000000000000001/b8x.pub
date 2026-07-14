module Inter.Ui.Page.Article.Hero.Header.Lead.Style
  (class'
  , lead
  , lead_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (color, rgba)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Base (raw)
import Util.Style.Selector ((.?))
import Util.Style.Layout (marginBottom, marginTop)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Typography (fontSizeRem)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Header.Lead.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    fontSizeRem 1.5
    raw "line-height" "1.5"
    color $ rgba 51 51 51 1.0
    raw "text-shadow" "0 0 0.5rem rgba(255,255,255,1.0), 0 0 1rem rgba(255,255,255,0.8)"
    marginTop 0.0
    marginBottom 0.0

lead :: ∀ w i. InstanceId -> Node HTMLdiv w i
lead id props = div ([ classes [ staticClass, class' id ] ] <> props)

lead_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
lead_ id = lead id []
