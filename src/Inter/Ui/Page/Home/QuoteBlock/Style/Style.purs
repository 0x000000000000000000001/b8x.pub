module Inter.Ui.Page.Home.QuoteBlock.Style.Style
  ( fullModuleName
  , staticClass
  , staticStyle
  , quoteBlock
  , quoteBlock_
  , leftCol
  , leftCol_
  , rightCol
  , rightCol_
  , articleTitle
  , articleTitle_
  , quoteText
  , quoteText_
  , quoteImage
  , quoteImage_
  , imageBand
  , imageBand_
  , quoteIcon
  , quoteIcon_
  , quoteTitle
  , quoteTitle_
  , quoteImageBlur
  , quoteImageContain
  ) where

import Proem hiding (div)

import CSS (bold, color, column, flexDirection, fontSize, fontWeight, justifyContent, marginBottom, pct, px, rem, row, spaceBetween)
import CSS as CSS
import CSS.Font (serif)
import CSS.Transform (transforms, scale)
import DOM.HTML.Indexed (HTMLdiv, HTMLimg)
import Data.NonEmpty ((:|))
import Halogen.HTML (HTML, Leaf, Node, div, img)
import Util.Power (isPowerful)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Color as Color
import Util.Style.Layout (displayFlex, widthPct100)
import Util.Style.Selector ((.?), (.*), (¨*), (:&))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Home.QuoteBlock.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

leftColClass :: String
leftColClass = staticClass <> "-left"

rightColClass :: String
rightColClass = staticClass <> "-right"

articleTitleClass :: String
articleTitleClass = staticClass <> "-title"

quoteTextClass :: String
quoteTextClass = staticClass <> "-text"

quoteImageClass :: String
quoteImageClass = staticClass <> "-image"

quoteIconClass :: String
quoteIconClass = staticClass <> "-icon"

quoteTitleClass :: String
quoteTitleClass = staticClass <> "-quote-title"

quoteImageBlurClass :: String
quoteImageBlurClass = staticClass <> "-image-blur"

quoteImageContainClass :: String
quoteImageContainClass = staticClass <> "-image-contain"

imageBandClass :: String
imageBandClass = staticClass <> "-image-band"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    CSS.width (pct 80.0)
    CSS.marginLeft (pct 10.0)
    CSS.marginRight (pct 10.0)
    CSS.marginTop (rem 6.0)
    displayFlex
    flexDirection row
    CSS.key (CSS.fromString "flex-wrap") "nowrap"
    justifyContent spaceBetween
    CSS.key (CSS.fromString "align-items") "stretch"
    CSS.position CSS.relative
    CSS.backgroundColor (CSS.rgba 255 255 255 0.7)
    CSS.borderRadius (rem 1.0) (rem 1.0) (rem 1.0) (rem 1.0)
    CSS.key (CSS.fromString "box-shadow") "0px 20px 40px rgba(0,0,0,0.08)"
    CSS.key (CSS.fromString "cursor") "pointer"
    CSS.key (CSS.fromString "transition") "transform 0.3s ease, box-shadow 0.3s ease"

    CSS.hover :& do
      CSS.key (CSS.fromString "transform") "translateY(-4px)"
      CSS.key (CSS.fromString "box-shadow") "0px 25px 50px rgba(0,0,0,0.12)"

      quoteImageClass .* do
        "img" ¨* do
          when isPowerful $ transforms [ scale 1.05 1.05 ]

        quoteImageBlurClass .* do
          when isPowerful $ transforms [ scale 1.15 1.15 ]

  leftColClass .? do
    displayFlex
    flexDirection column
    CSS.key (CSS.fromString "flex") "1 1 60%"
    CSS.padding (rem 4.0) (rem 4.0) (rem 4.0) (rem 4.0)
    CSS.position CSS.relative
    CSS.zIndex 1
    CSS.key (CSS.fromString "justify-content") "center"

  rightColClass .? do
    displayFlex
    CSS.key (CSS.fromString "flex") "0 0 40%"
    CSS.position CSS.relative
    CSS.zIndex 2
    CSS.key (CSS.fromString "overflow") "hidden"
    CSS.key (CSS.fromString "border-top-right-radius") "1rem"
    CSS.key (CSS.fromString "border-bottom-right-radius") "1rem"
    -- Fix WebKit bug where border-radius is ignored during children transform animations (e.g. image hover zoom)
    CSS.key (CSS.fromString "transform") "translateZ(0)"
    CSS.key (CSS.fromString "-webkit-mask-image") "-webkit-radial-gradient(white, black)"

  quoteTextClass .? do
    CSS.position CSS.relative
    CSS.zIndex 1
    CSS.key (CSS.fromString "font-weight") "400"
    CSS.key (CSS.fromString "font-style") "italic"
    fontSize (rem 1.8)
    CSS.fontFamily [ "Georgia", "Times New Roman" ] (serif :| [])
    CSS.lineHeight (pct 150.0)
    color (CSS.rgb 70 70 70)

  quoteTitleClass .? do
    CSS.position CSS.absolute
    CSS.key (CSS.fromString "top") "0"
    CSS.key (CSS.fromString "left") "50%"
    CSS.key (CSS.fromString "transform") "translateX(-50%) translateY(-50%)"
    CSS.backgroundColor Color.red
    color CSS.white
    fontSize (rem 1.4)
    fontWeight bold
    CSS.key (CSS.fromString "text-transform") "uppercase"
    CSS.key (CSS.fromString "letter-spacing") "0.1rem"
    CSS.padding (rem 0.4) (rem 2.0) (rem 0.4) (rem 2.0)
    CSS.borderRadius (rem 2.0) (rem 2.0) (rem 2.0) (rem 2.0)
    CSS.key (CSS.fromString "box-shadow") "0 4px 14px rgba(220, 38, 38, 0.4)"
    CSS.key (CSS.fromString "z-index") "10"

  quoteIconClass .? do
    CSS.position CSS.absolute
    CSS.key (CSS.fromString "top") "-0.25rem"
    CSS.key (CSS.fromString "left") "1.7rem"
    CSS.width (rem 5.0)
    CSS.height (rem 5.0)
    CSS.key (CSS.fromString "background-image") "url('/asset/image/quote.png')"
    CSS.key (CSS.fromString "background-size") "contain"
    CSS.key (CSS.fromString "background-repeat") "no-repeat"
    CSS.key (CSS.fromString "opacity") "0.15"
    CSS.key (CSS.fromString "pointer-events") "none"
    CSS.key (CSS.fromString "z-index") "0"

  quoteImageClass .? do
    CSS.position CSS.absolute
    CSS.top (px 0.0)
    CSS.left (px 0.0)
    widthPct100
    CSS.height (pct 100.0)

    "img" ¨* do
      CSS.height (pct 100.0)
      widthPct100
      CSS.key (CSS.fromString "object-fit") "cover"
      CSS.key (CSS.fromString "transition") "transform 0.3s ease"

    quoteImageBlurClass .* do
      CSS.position CSS.absolute
      widthPct100
      CSS.height (pct 100.0)
      CSS.key (CSS.fromString "object-fit") "cover"
      if isPowerful then
        CSS.key (CSS.fromString "filter") "blur(0.6rem)"
      else do
        CSS.key (CSS.fromString "filter") "blur(0.3rem)"
        CSS.opacity 0.8
      transforms [ scale 1.1 1.1 ]
      CSS.zIndex 0

    quoteImageContainClass .* do
      CSS.position CSS.relative
      widthPct100
      CSS.height (pct 100.0)
      CSS.key (CSS.fromString "object-fit") "contain"
      CSS.zIndex 1
      CSS.key (CSS.fromString "transition") "transform 0.3s ease"

  imageBandClass .? do
    CSS.position CSS.absolute
    CSS.bottom (px 0.0)
    CSS.left (px 0.0)
    widthPct100
    CSS.backgroundColor (CSS.rgba 0 0 0 0.5)
    CSS.key (CSS.fromString "backdrop-filter") "blur(4px)"
    CSS.padding (rem 0.8) (rem 0.5) (rem 0.5) (rem 0.5)
    CSS.zIndex 2

  articleTitleClass .? do
    color (CSS.rgb 255 255 255)
    fontSize (rem 0.95)
    marginBottom (px 0.0)
    CSS.fontFamily [ "Georgia", "Times New Roman" ] (serif :| [])
    CSS.key (CSS.fromString "text-align") "center"

quoteBlock :: ∀ w i. Node HTMLdiv w i
quoteBlock props = div ([ class_ staticClass ] <> props)

quoteBlock_ :: ∀ w i. Array (HTML w i) -> HTML w i
quoteBlock_ = quoteBlock []

leftCol :: ∀ w i. Node HTMLdiv w i
leftCol props = div ([ class_ leftColClass ] <> props)

leftCol_ :: ∀ w i. Array (HTML w i) -> HTML w i
leftCol_ = leftCol []

rightCol :: ∀ w i. Node HTMLdiv w i
rightCol props = div ([ class_ rightColClass ] <> props)

rightCol_ :: ∀ w i. Array (HTML w i) -> HTML w i
rightCol_ = rightCol []

articleTitle :: ∀ w i. Node HTMLdiv w i
articleTitle props = div ([ class_ articleTitleClass ] <> props)

articleTitle_ :: ∀ w i. Array (HTML w i) -> HTML w i
articleTitle_ = articleTitle []

quoteText :: ∀ w i. Node HTMLdiv w i
quoteText props = div ([ class_ quoteTextClass ] <> props)

quoteText_ :: ∀ w i. Array (HTML w i) -> HTML w i
quoteText_ = quoteText []

quoteImage :: ∀ w i. Node HTMLdiv w i
quoteImage props = div ([ class_ quoteImageClass ] <> props)

quoteImage_ :: ∀ w i. Array (HTML w i) -> HTML w i
quoteImage_ = quoteImage []

imageBand :: ∀ w i. Node HTMLdiv w i
imageBand props = div ([ class_ imageBandClass ] <> props)

imageBand_ :: ∀ w i. Array (HTML w i) -> HTML w i
imageBand_ = imageBand []

quoteIcon :: ∀ w i. Node HTMLdiv w i
quoteIcon props = div ([ class_ quoteIconClass ] <> props)

quoteIcon_ :: ∀ w i. Array (HTML w i) -> HTML w i
quoteIcon_ = quoteIcon []

quoteTitle :: ∀ w i. Node HTMLdiv w i
quoteTitle props = div ([ class_ quoteTitleClass ] <> props)

quoteTitle_ :: ∀ w i. Array (HTML w i) -> HTML w i
quoteTitle_ = quoteTitle []

quoteImageBlur :: ∀ w i. Leaf HTMLimg w i
quoteImageBlur props = img ([ class_ quoteImageBlurClass ] <> props)

quoteImageContain :: ∀ w i. Leaf HTMLimg w i
quoteImageContain props = img ([ class_ quoteImageContainClass ] <> props)
