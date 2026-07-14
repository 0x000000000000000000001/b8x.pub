module Inter.Ui.Page.Article.Content.Notes.Style
  (fullModuleName
  , staticClass
  , staticStyle
  , notes
  , notes_
  , title
  , title_
  ) where

import Proem hiding (div)

import CSS (CSS, backgroundColor, color, rgba, textTransform)
import CSS as CSS
import CSS.Text.Transform (uppercase)
import DOM.HTML.Indexed (HTMLdiv, HTMLh3)
import Halogen.HTML (HTML, Node, div, h3)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Anchor (centerToTopCenter)
import Util.Style.Base (raw)
import Util.Style.Classname (classes, class_, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Effect (borderRadiusRem1)
import Util.Style.Layout (margin0, marginTop, padding4, maxWidthRem, widthPct)
import Util.Style.Position (positionRelative)
import Util.Style.Selector ((.?))
import Util.Style.Typography (fontSizeRem, fontWeightBold, letterSpacingRem)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Content.Notes.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

titleClass :: String
titleClass = refineClass' staticClass "title"

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    maxWidthRem 45.0
    raw "margin" "0 auto"
    widthPct 100.0
    marginTop 7.0
    backgroundColor $ rgba 245 245 245 1.0
    raw "border-radius" "0.5rem"
    padding4 2.5 2.0 1.5 2.0 -- Increased top padding to give room for the label
    fontSizeRem 0.95
    raw "line-height" "1.6"
    color $ rgba 100 100 100 1.0
    positionRelative

  titleClass .? do
    margin0
    centerToTopCenter
    backgroundColor $ rgba 180 180 180 1.0
    color CSS.white
    fontSizeRem 0.85
    fontWeightBold
    textTransform uppercase
    letterSpacingRem 0.1
    padding4 0.3 1.5 0.3 1.5
    borderRadiusRem1 2.0
    raw "box-shadow" "0 2px 8px rgba(0, 0, 0, 0.1)"

notes :: ∀ w i. InstanceId -> Node HTMLdiv w i
notes id props = div ([ classes [ staticClass, class' id ] ] <> props)

notes_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
notes_ id = notes id []

title :: ∀ w i. Node HTMLh3 w i
title props = h3 ([ class_ titleClass ] <> props)

title_ :: ∀ w i. Array (HTML w i) -> HTML w i
title_ = title []
