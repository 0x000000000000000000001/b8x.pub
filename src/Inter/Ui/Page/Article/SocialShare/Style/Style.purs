module Inter.Ui.Page.Article.SocialShare.Style.Style
  ( fullModuleName
  , staticClass
  , staticStyle
  , socialShare
  , socialShare_
  , socialShareInner
  , socialShareInner_
  ) where

import Proem hiding (div, top, bottom)

import CSS as CSS
import CSS (flexDirection, hover, row, zIndex)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Base (raw)
import Util.Style.Classname (class_, generateStaticClass, refineClass')
import Util.Style.Color as Color
import Util.Style.Layout (alignItemsCenter, displayFlex, gapRem, heightRem, maxWidthRem, widthPct, widthRem, justifyContentCenter, marginTop, marginBottom)
import Util.Style.Effect (cursorPointer, fill)
import Util.Style.Position (positionRelative)
import Util.Style.Selector (svg, (.?), (:&), (:*))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.SocialShare.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticInnerClass :: String
staticInnerClass = refineClass' staticClass "inner"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionRelative
    maxWidthRem 45.0
    raw "margin" "0 auto"
    widthPct 100.0
    marginTop 6.0
    marginBottom 2.0

  staticInnerClass .? do
    displayFlex
    flexDirection row
    justifyContentCenter
    alignItemsCenter
    gapRem 1.5
    zIndex 10

    svg :* do
      widthRem 1.5
      heightRem 1.5
      fill Color.red
      cursorPointer

    hover :& do
      svg :* do
        fill Color.textRed

socialShare :: ∀ w i. Node HTMLdiv w i
socialShare props = div ([ class_ staticClass ] <> props)

socialShare_ :: ∀ w i. Array (HTML w i) -> HTML w i
socialShare_ = socialShare []

socialShareInner :: ∀ w i. Node HTMLdiv w i
socialShareInner props = div ([ class_ staticInnerClass ] <> props)

socialShareInner_ :: ∀ w i. Array (HTML w i) -> HTML w i
socialShareInner_ = socialShareInner []
