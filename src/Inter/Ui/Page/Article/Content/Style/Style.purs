module Inter.Ui.Page.Article.Content.Style.Style
  ( class'
  , content
  , content_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (backgroundColor, flexGrow, rgba)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Base (raw)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Effect (boxShadow)
import Util.Style.Layout (heightAuto, marginTop, padding4, paddingTop, widthPct)
import Util.Style.Position (positionRelative)
import Util.Style.Selector ((.?), (¨*))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Content.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticClassWhenShifted :: String
staticClassWhenShifted = refineClass' staticClass "shifted"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    flexGrow 1.0
    raw "margin" "0 auto"
    widthPct 100.0
    backgroundColor $ rgba 253 249 247 1.0
    boxShadow 0.0 5.0 20.0 $ rgba 0 0 0 0.05
    padding4 4.0 2.0 6.0 2.0
    marginTop 0.0
    positionRelative

    "img" ¨* do
      widthPct 100.0
      heightAuto

    "figure" ¨* do
      raw "margin" "1.4rem 0"
      widthPct 100.0

    "figure img" ¨* do
      widthPct 100.0
      heightAuto

    "iframe" ¨* do
      widthPct 100.0

    "a:has(img)" ¨* do
      raw "display" "block"
      widthPct 100.0

    "a:has(img) img" ¨* do
      widthPct 100.0
      heightAuto

  staticClassWhenShifted .? do
    paddingTop 15.0
    marginTop (-15.0)

content :: ∀ w i. InstanceId -> Boolean -> Node HTMLdiv w i
content id isShifted props = div ([ classes ([ staticClass, class' id ] <> if isShifted then [ staticClassWhenShifted ] else []) ] <> props)

content_ :: ∀ w i. InstanceId -> Boolean -> Array (HTML w i) -> HTML w i
content_ id isShifted = content id isShifted []
