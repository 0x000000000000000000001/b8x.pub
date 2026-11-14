module Inter.Ui.Router.Header.Logo.Style
  ( logo
  , logo_
  , containerClass
  , baselineClass
  , staticClass
  , staticStyle
  ) where

import Proem hiding (top, div)

import CSS (alignSelf, animation, ease, forwards, fromString, infinite, keyframes, normalAnimationDirection, sec, flexDirection, column)
import CSS as CSS
import CSS.Common (center)
import DOM.HTML.Indexed (HTMLimg)
import Data.NonEmpty ((:|))
import Data.Tuple.Nested ((/\))
import Halogen.HTML (HTML, Leaf, img)
import CSS.Transform (transforms, scale)
import Util.Style.Classname (class_, generateStaticClass, inferAnimationId)
import Util.Style.Layout (heightRem, margin4, alignItemsCenter, marginTop)
import Util.Style.Effect (cursorPointer)
import Util.Power (isPowerful)
import Util.Style.Selector ((.?))
import Util.Style.MediaQuery (onMobileLte)
import Util.Style.Typography (secondaryFont, textAlignCenter, fontSizeRem)
import Util.Style.Base (raw)
import Util.Style.Color (colorRed)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Header.Logo.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

containerClass :: String
containerClass = generateStaticClass (fullModuleName <> ".Container")

baselineClass :: String
baselineClass = generateStaticClass (fullModuleName <> ".Baseline")

animationId :: String
animationId = inferAnimationId staticClass

staticStyle :: CSS.CSS
staticStyle = do
  containerClass .? do
    flexDirection column
    alignItemsCenter
    alignSelf center
    margin4 1.7 1.0 1.0 1.0
    cursorPointer

  staticClass .? do
    heightRem 7.5
    onMobileLte do
      heightRem 5.2

  baselineClass .? do
    secondaryFont
    raw "font-style" "italic"
    textAlignCenter
    fontSizeRem 1.13
    onMobileLte do
      fontSizeRem 0.79
    colorRed
    marginTop 0.2

    when isPowerful $ animation
      (fromString animationId)
      (sec 15.0)
      ease
      (sec 0.0)
      infinite
      normalAnimationDirection
      forwards

  keyframes animationId
    ( 0.0 /\ do
        transforms [ scale 1.0 1.0 ]
        :|
          [ 50.0 /\ do
              transforms [ scale 1.04 1.04 ]
          , 100.0 /\ do
              transforms [ scale 1.0 1.0 ]
          ]
    )

logo :: ∀ w i. Leaf HTMLimg w i
logo props = img ([ class_ staticClass ] <> props)

logo_ :: ∀ w i. HTML w i
logo_ = logo []
