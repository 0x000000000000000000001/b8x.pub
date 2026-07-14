module Inter.Ui.Mod.ArticlesBand.Style
  (fullModuleName
  , staticClass
  , staticStyle
  , articlesBand
  , articlesBand_
  , title
  , title_
  , content
  , content_
  , articleContainer
  , articleContainer_
  ) where

import Proem hiding (div, top)

import CSS (backgroundColor, borderBox, boxSizing, color, column, flexDirection, hover, maxWidth, rem, rgba, textTransform, borderColor, fromString)
import CSS as CSS
import CSS.Size (px, pct, calcSum)
import CSS.Text.Transform (uppercase)
import CSS.Transform (transforms, translateY)
import DOM.HTML.Indexed (HTMLdiv, HTMLh3)
import Halogen.HTML (HTML, Node, div, h3)
import Inter.Ui.Mod.ArticleCard.Style as ArticleCardStyle
import Util.Style.Anchor (centerToTopCenter)
import Util.Style.Base (raw)
import Util.Style.Classname (class_, generateStaticClass, refineClass')
import Util.Style.Color as Color
import Util.Style.Effect (borderRadiusRem1, whiteGlassBackground)
import Util.Style.Layout (displayFlex, gapRem, padding4, widthPct100, margin0, marginTop)
import Util.Style.Position (positionRelative)
import Util.Style.Selector ((.?), (.*), (:&))
import Util.Style.Typography (fontSizeRem, fontWeightBold, letterSpacingRem)
import Util.Power (isPowerful)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.ArticlesBand.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

titleClass :: String
titleClass = refineClass' staticClass "title"

contentClass :: String
contentClass = refineClass' staticClass "content"

articleContainerClass :: String
articleContainerClass = refineClass' staticClass "article-container"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    maxWidth (calcSum (pct 100.0) (rem (-6.0)))
    marginTop 7.0
    raw "margin-left" "auto"
    raw "margin-right" "auto"
    displayFlex
    flexDirection column
    gapRem 1.5
    padding4 3.8 2.0 2.0 2.0
    boxSizing borderBox
    positionRelative

    -- Glassmorphism & Contours
    whiteGlassBackground
    borderRadiusRem1 1.0

    hover :& do
      backgroundColor $ rgba 255 255 255 0.95
      when isPowerful $ transforms [ translateY (px (-2.0)) ]

    fromString "::after" :& do
      raw "content" "\"\""
      raw "position" "absolute"
      raw "top" "0"
      raw "right" "0"
      raw "bottom" "0"
      raw "width" "12rem"
      raw "background" "linear-gradient(to right, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 1) 100%)"
      raw "border-top-right-radius" "1rem"
      raw "border-bottom-right-radius" "1rem"
      raw "pointer-events" "none"
      raw "z-index" "10"

  titleClass .? do
    margin0
    centerToTopCenter
    backgroundColor Color.red
    color CSS.white
    fontSizeRem 1.4
    fontWeightBold
    textTransform uppercase
    letterSpacingRem 0.1
    padding4 0.4 2.0 0.4 2.0
    borderRadiusRem1 2.0
    raw "box-shadow" "0 4px 14px rgba(220, 38, 38, 0.4)"

  contentClass .? do
    widthPct100
    displayFlex
    flexDirection CSS.row
    gapRem 0.0
    raw "overflow-x" "auto"
    padding4 0.5 12.0 1.0 1.0

  articleContainerClass .? do
    CSS.minWidth (px 350.0)
    CSS.maxWidth (px 350.0)
    CSS.height (pct 100.0)
    raw "flex-shrink" "0"

    fromString ":first-child" :& do
      raw "margin-left" "auto"

    fromString ":last-child" :& do
      raw "margin-right" "auto"

    let
      notHovered = fromString ":not(:hover)"

    ArticleCardStyle.staticClass .* do
      notHovered :& do
        backgroundColor Color.transparent
        borderColor Color.transparent
        raw "backdrop-filter" "none"
        raw "box-shadow" "none"

articlesBand :: ∀ w i. Node HTMLdiv w i
articlesBand props = div ([ class_ staticClass ] <> props)

articlesBand_ :: ∀ w i. Array (HTML w i) -> HTML w i
articlesBand_ = articlesBand []

title :: ∀ w i. Node HTMLh3 w i
title props = h3 ([ class_ titleClass ] <> props)

title_ :: ∀ w i. Array (HTML w i) -> HTML w i
title_ = title []

content :: ∀ w i. Node HTMLdiv w i
content props = div ([ class_ contentClass ] <> props)

content_ :: ∀ w i. Array (HTML w i) -> HTML w i
content_ = content []

articleContainer :: ∀ w i. Node HTMLdiv w i
articleContainer props = div ([ class_ articleContainerClass ] <> props)

articleContainer_ :: ∀ w i. Array (HTML w i) -> HTML w i
articleContainer_ = articleContainer []
