module Inter.Ui.Page.Donate.Style.Style where

import Proem hiding (div)

import CSS (CSS, alignItems, backgroundColor, border, borderRadius, color, column, display, flex, flexDirection, fontSize, height, hover, justifyContent, marginBottom, marginRight, marginTop, padding, px, rem, solid, width)
import CSS.Common (center)
import CSS.Cursor (cursor, pointer)
import CSS.String (fromString)
import Color as Color
import Halogen.HTML (HTML, div)
import Util.Style.Base (raw)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (margin0, padding1)
import Util.Style.Selector ((.?), (¨?), (:&))
import Util.Style.Typography (textAlignCenter)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Donate.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    width (fromString "100%")
    display flex
    flexDirection column
    alignItems center
    justifyContent center
    padding1 2.0

    ".donate-container" ¨? do
      width (fromString "100%")
      raw "max-width" "800px"
      display flex
      flexDirection column
      alignItems center

    ".donate-title" ¨? do
      margin0
      fontSize (rem 3.5)
      raw "font-weight" "800"
      color (Color.rgba 20 20 20 1.0)
      marginBottom (rem 0.5)
      textAlignCenter

    ".donate-subtitle" ¨? do
      fontSize (rem 1.2)
      color (Color.rgba 100 100 100 1.0)
      marginBottom (rem 4.0)
      textAlignCenter
      raw "max-width" "600px"

    ".donate-steps" ¨? do
      display flex
      flexDirection column
      width (fromString "100%")

    ".donate-step" ¨? do
      display flex
      raw "flex-direction" "row"
      marginBottom (rem 3.0)
      raw "align-items" "flex-start"
      padding (rem 2.0) (rem 2.0) (rem 2.0) (rem 2.0)
      backgroundColor Color.white
      borderRadius (rem 1.0) (rem 1.0) (rem 1.0) (rem 1.0)
      raw "box-shadow" "0 10px 30px rgba(0,0,0,0.05)"
      raw "transition" "transform 0.2s ease, box-shadow 0.2s ease"

      hover :& do
        raw "transform" "translateY(-5px)"
        raw "box-shadow" "0 15px 35px rgba(0,0,0,0.1)"

    ".step-number" ¨? do
      display flex
      alignItems center
      justifyContent center
      width (rem 3.5)
      height (rem 3.5)
      raw "min-width" "3.5rem"
      backgroundColor (Color.rgba 220 20 60 1.0)
      color Color.white
      raw "border-radius" "50%"
      fontSize (rem 1.5)
      raw "font-weight" "bold"
      marginRight (rem 1.5)

    ".step-content" ¨? do
      display flex
      flexDirection column
      justifyContent center

    ".step-title" ¨? do
      fontSize (rem 1.4)
      raw "font-weight" "700"
      color (Color.rgba 20 20 20 1.0)
      marginBottom (rem 0.5)
      marginTop (px 0.0)

    ".step-desc" ¨? do
      fontSize (rem 1.1)
      color (Color.rgba 80 80 80 1.0)
      marginBottom (rem 1.0)
      raw "line-height" "1.5"

    ".step-action" ¨? do
      raw "display" "inline-flex"
      alignItems center
      justifyContent center
      padding (rem 0.8) (rem 1.5) (rem 0.8) (rem 1.5)
      backgroundColor (Color.rgba 220 20 60 1.0)
      color Color.white
      raw "font-weight" "600"
      borderRadius (rem 2.0) (rem 2.0) (rem 2.0) (rem 2.0)
      raw "text-decoration" "none"
      border solid (px 0.0) (Color.rgba 220 20 60 1.0)
      cursor pointer
      raw "transition" "background-color 0.2s ease"
      fontSize (rem 1.0)
      raw "align-self" "flex-start"

      hover :& do
        backgroundColor (Color.rgba 180 0 0 1.0)
        color Color.white

donate_ :: ∀ w i. Array (HTML w i) -> HTML w i
donate_ children = div [ class_ staticClass ] children
