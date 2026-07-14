module Inter.Ui.Page.Article.Content.Body.Style
  (fullModuleName
  , class'
  , body
  , body_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (color, float, floatLeft, fontFamily, rgba)
import CSS as CSS
import CSS.Font (serif)
import DOM.HTML.Indexed (HTMLdiv)
import Data.NonEmpty ((:|))
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Base (raw)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Layout (marginBottom, marginTop, maxWidthRem, paddingRight, widthPct)
import Util.Style.Selector (firstLetter, (.?), (:&))
import Util.Style.Typography (fontSizePct, fontSizeRem, lineHeight)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Content.Body.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    maxWidthRem 45.0
    raw "margin" "0 auto"
    widthPct 100.0
    fontSizePct 145.0
    raw "line-height" "1.8"
    raw "letter-spacing" "0.01rem"
    color $ rgba 51 51 51 1.0

    firstLetter :& do
      float floatLeft
      fontSizeRem 6.5
      lineHeight 0.85
      marginTop (-0.1)
      marginBottom (-0.4)
      paddingRight 0.35
      fontFamily [ "Georgia" ] (serif :| [])

body :: ∀ w i. InstanceId -> Node HTMLdiv w i
body id props = div ([ classes [ staticClass, class' id ] ] <> props)

body_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
body_ id = body id []
