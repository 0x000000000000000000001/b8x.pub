module Inter.Ui.Page.Article.Hero.Style.Style
  (class'
  , hero
  , hero_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (alignItems, column, flexDirection, flexStart, row)
import CSS as CSS
import CSS.Common (center)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout(..))
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Base (raw)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Layout (displayFlex, gapRem, maxWidthRem, padding4, widthPct)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Style.Style"

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
    widthPct 100.0
    maxWidthRem 80.0
    raw "margin" "0 auto"
    padding4 2.0 2.0 4.0 2.0
    gapRem 3.0

  staticClassWhenPortrait .? do
    flexDirection row
    alignItems flexStart

  staticClassWhenLandscape .? do
    flexDirection column
    alignItems center

  staticClassWhenTextOnly .? do
    flexDirection column
    alignItems center

hero :: ∀ w i. InstanceId -> IllustrationLayout -> Node HTMLdiv w i
hero id layout props = div
  ([ classes
        [ staticClass
        , case layout of
            Side -> staticClassWhenPortrait
            CentralShifted -> staticClassWhenLandscape
            TextOnly -> staticClassWhenTextOnly
        , class' id
        ]
    ] <> props
  )

hero_ :: ∀ w i. InstanceId -> IllustrationLayout -> Array (HTML w i) -> HTML w i
hero_ id layout = hero id layout []
