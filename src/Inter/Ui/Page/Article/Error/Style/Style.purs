module Inter.Ui.Page.Article.Error.Style.Style
  (container_
  , image_
  , text_
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (column, flexDirection, fontSize, fontWeight, marginTop, padding, px, rem)
import CSS as CSS
import DOM.HTML.Indexed (HTMLimg)
import Halogen.HTML (HTML, div, img)
import Halogen.HTML.Properties (IProp)
import Util.Style.Base (raw)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Color (colorRed)
import Util.Style.Layout (alignItemsCenter, displayFlex, justifyContentCenter, widthPct)
import Util.Style.Selector ((.?))
import Util.Style.Typography (textAlignCenter)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Error.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

textClass :: String
textClass = generateStaticClass (fullModuleName <> ".Text")

imageClass :: String
imageClass = generateStaticClass (fullModuleName <> ".Image")

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayFlex
    flexDirection column
    alignItemsCenter
    justifyContentCenter
    widthPct 100.0
    padding (rem 4.0) (rem 2.0) (rem 4.0) (rem 2.0)

  imageClass .? do
    widthPct 100.0
    CSS.maxWidth (px 250.0)
    raw "margin" "0 auto"

  textClass .? do
    marginTop (rem 2.0)
    fontSize (rem 1.5)
    fontWeight (CSS.weight 600.0)
    colorRed
    textAlignCenter

container_ :: ∀ w i. Array (HTML w i) -> HTML w i
container_ = div [ classes [ staticClass ] ]

image_ :: ∀ w i. Array (IProp HTMLimg i) -> HTML w i
image_ props = img ([ classes [ imageClass ] ] <> props)

text_ :: ∀ w i. Array (HTML w i) -> HTML w i
text_ = div [ classes [ textClass ] ]
