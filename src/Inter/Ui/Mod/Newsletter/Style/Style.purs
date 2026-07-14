module Inter.Ui.Mod.Newsletter.Style.Style
  ( fullModuleName
  , booksletter
  , booksletter_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (CSS, key, rgba, weight, width) as CSS
import CSS (backgroundColor, border, borderRadius, button, color, flexDirection, fontSize, fontWeight, form, fromString, h3, img, input, marginTop, p, px, rem, row, solid)
import CSS.Color (white, black)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node)
import Halogen.HTML as HH
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Color (red, transparent, limegreen)
import Util.Style.Layout (displayFlex, justifyContentCenter, alignItemsCenter, widthPct100, padding2, margin2)
import Util.Style.Selector (disabled, div, (:<), (:&), (.&), (.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Newsletter.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = staticClass .? do
  marginTop (rem 5.0)
  widthPct100
  displayFlex
  flexDirection row
  CSS.key (fromString "flex-wrap") "wrap"
  alignItemsCenter
  justifyContentCenter
  padding2 5.5 1.0
  backgroundColor transparent
  CSS.key (fromString "position") "relative"

  img :< do
    CSS.width (px 550.0)
    CSS.key (fromString "position") "absolute"
    CSS.key (fromString "left") "-6rem"
    CSS.key (fromString "top") "50%"
    CSS.key (fromString "transform") "translateY(-50%)"
    CSS.key (fromString "z-index") "-1"
    CSS.key (fromString "opacity") "1"

  div :< do
    displayFlex
    CSS.key (fromString "flex-direction") "column"
    alignItemsCenter
    CSS.key (fromString "flex-basis") "800px"
    CSS.key (fromString "flex-grow") "0"
    CSS.key (fromString "z-index") "1"

    h3 :< do
      fontSize (rem 3.0)
      fontWeight (CSS.weight 800.0)
      margin2 0.5 0.0
      color black
      CSS.key (fromString "text-align") "center"

    p :< do
      fontSize (rem 1.4)
      margin2 0.5 0.0
      color black
      CSS.key (fromString "text-align") "center"

    form :< do
      displayFlex
      flexDirection row
      marginTop (rem 1.5)
      widthPct100
      CSS.key (fromString "max-width") "600px"

      div :< do
        CSS.key (fromString "flex-grow") "1"

      input :< do
        border solid (px 1.0) red
        borderRadius (px 4.0) (px 0.0) (px 0.0) (px 4.0)
        CSS.key (fromString "outline") "none"

      button :< do
        padding2 0.0 2.0
        fontSize (rem 1.2)
        fontWeight (CSS.weight 700.0)
        backgroundColor red
        color white
        border solid (px 1.0) red
        borderRadius (px 0.0) (px 4.0) (px 4.0) (px 0.0)
        CSS.key (fromString "cursor") "pointer"
        CSS.key (fromString "white-space") "nowrap"

        disabled :& do
          backgroundColor (CSS.rgba 200 200 200 1.0)
          border solid (px 1.0) (CSS.rgba 200 200 200 1.0)
          CSS.key (fromString "cursor") "not-allowed"

        "blue" .& do
          backgroundColor (CSS.rgba 0 123 255 1.0)
          border solid (px 1.0) (CSS.rgba 0 123 255 1.0)

        "green" .& do
          backgroundColor limegreen
          border solid (px 1.0) limegreen

booksletter :: ∀ w i. Node HTMLdiv w i
booksletter compProps = HH.div ([ class_ staticClass ] <> compProps)

booksletter_ :: ∀ w i. Array (HTML w i) -> HTML w i
booksletter_ = booksletter []


