module Inter.Ui.Page.Article.Hero.Header.Style.Style
  (class'
  , header
  , header_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (alignItems, column, flexBasis, flexDirection, flexGrow, flexShrink, pct)
import CSS as CSS
import CSS.Common (center)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Layout (displayFlex, gapRem, maxWidthRem)
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout(..))
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Selector ((.?))
import Util.Style.Typography (textAlignCenter)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Header.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticClassWhenPortrait :: String
staticClassWhenPortrait = refineClass' staticClass "portrait"

staticClassWhenLandscape :: String
staticClassWhenLandscape = refineClass' staticClass "landscape"

staticClassWhenTextOnly :: String
staticClassWhenTextOnly = refineClass' staticClass "textOnly"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayFlex
    flexDirection column
    gapRem 1.5
    flexGrow 1.0
    flexShrink 1.0

  staticClassWhenPortrait .? do
    flexBasis (pct 70.0)

  staticClassWhenLandscape .? do
    alignItems center
    textAlignCenter
    maxWidthRem 50.0

  staticClassWhenTextOnly .? do
    alignItems center
    textAlignCenter
    maxWidthRem 50.0

header :: ∀ w i. InstanceId -> IllustrationLayout -> Node HTMLdiv w i
header id layout props = div
  ([ classes
        ([ staticClass, class' id ] <> case layout of
            Side -> [ staticClassWhenPortrait ]
            CentralShifted -> [ staticClassWhenLandscape ]
            TextOnly -> [ staticClassWhenTextOnly ]
        )
    ] <> props
  )

header_ :: ∀ w i. InstanceId -> IllustrationLayout -> Array (HTML w i) -> HTML w i
header_ id layout = header id layout []
