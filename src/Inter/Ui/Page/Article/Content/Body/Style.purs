module Inter.Ui.Page.Article.Content.Body.Style
  ( fullModuleName
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
import Util.Style.MediaQuery (onMobileLte)
import Util.Style.Selector (firstLetter, (.?), (:&), (¨*))
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

    onMobileLte do
      fontSizePct 115.0
      raw "line-height" "1.6"

    firstLetter :& do
      float floatLeft
      fontSizeRem 6.5
      lineHeight 0.85
      marginTop (-0.1)
      marginBottom (-0.4)
      paddingRight 0.35
      fontFamily [ "Georgia" ] (serif :| [])

    "blockquote" ¨* do
      raw "border-left" "0.25rem solid hsl(353.9, 81.7%, 47.3%)"
      raw "padding-left" "1.25rem"
      raw "margin-left" "0"
      raw "margin-right" "0"
      raw "font-style" "italic"
      raw "color" "rgba(51, 51, 51, 0.75)"

body :: ∀ w i. InstanceId -> Node HTMLdiv w i
body id props = div ([ classes [ staticClass, class' id ] ] <> props)

body_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
body_ id = body id []
