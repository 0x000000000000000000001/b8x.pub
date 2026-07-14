module Inter.Ui.Router.Style.Style
  ( router
  , router_
  , staticClass
  , staticStyle
  , defaultTransitionTime
  ) where

import Proem hiding (top, div)

import CSS (Time, backgroundColor, backgroundPosition, body, color, column, figcaption, figure, flexDirection, fontStyle, fromString, hover, html, keyframes, positioned, rem, rgba)
import CSS as CSS
import CSS.FontStyle (italic)
import CSS.Time (ms, sec)
import CSS.Transition (ease)
import DOM.HTML.Indexed (HTMLdiv)
import Data.NonEmpty ((:|))
import Data.Tuple.Nested ((/\))
import Halogen.HTML (HTML, Node, div)
import Util.Style.Base (raw)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Effect (borderRadiusRem1, loadingShimmerAnimationId, loadingShimmerWidth)
import Util.Style.Layout (alignItemsCenter, boxSizingBorderBox, displayFlex, heightRem, justifyContentCenter, margin1, marginTop, overflowScrollingTouch, padding1, widthPct, widthRem)
import Util.Style.Selector (all, (:&), (:?), (¨?))
import Util.Style.Transition (transition)
import Util.Style.Transition as Transition
import Util.Style.Typography (fontSizeRem, primaryFont, textAlignCenter)
import Util.Style.Color (colorRed, textRed)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

defaultTransitionDurationMs :: Number
defaultTransitionDurationMs = 300.0

defaultTransitionTime :: Time
defaultTransitionTime = ms defaultTransitionDurationMs

staticStyle :: CSS.CSS
staticStyle = do
  html :? do
    primaryFont
    -- Momentum scrolling scrolling on iOS or Safari
    overflowScrollingTouch

  "input, textarea, button, select" ¨? do
    primaryFont

  CSS.a :? do
    colorRed
    raw "text-decoration-color" textRed

  figure :? do 
    displayFlex
    justifyContentCenter
    alignItemsCenter
    flexDirection column

  figcaption :? do
    widthPct 80.0
    marginTop 1.0
    fontSizeRem 0.9
    color $ rgba 51 51 51 0.7
    fontStyle italic
    textAlignCenter

  all :? do
    transition $ Transition.all defaultTransitionTime ease (sec 0.0)
    boxSizingBorderBox

    -- Firefox
    raw "scrollbar-width" "thin"
    raw "scrollbar-color" "rgba(0, 0, 0, 0.3) rgba(0, 0, 0, 0.05)"

    -- Chrome/Safari/Edge/...
    fromString "::-webkit-scrollbar" :& do
      widthRem 0.5
      heightRem 0.5

    fromString "::-webkit-scrollbar-track" :& do
      backgroundColor $ rgba 0 0 0 0.05

    fromString "::-webkit-scrollbar-thumb" :& do
      backgroundColor $ rgba 0 0 0 0.3
      borderRadiusRem1 0.25

      hover :& do
        backgroundColor $ rgba 0 0 0 0.5

    fromString "::-webkit-scrollbar-corner" :& do
      backgroundColor $ rgba 0 0 0 0.05

  keyframes loadingShimmerAnimationId
    ( 0.0 /\ backgroundPosition (positioned (rem $ -1.0 * loadingShimmerWidth) (rem 0.0))
        :|
          [ 50.0 /\ (raw "background-position" $ "calc(100% + " <> show loadingShimmerWidth <> "rem) 0")
          , 100.0 /\ (raw "background-position" $ "calc(100% + " <> show loadingShimmerWidth <> "rem) 0")
          ]
    )

  body :? do
    margin1 0.0
    padding1 0.0

router :: ∀ w i. Node HTMLdiv w i
router props = div ([ class_ staticClass ] <> props)

router_ :: ∀ w i. Array (HTML w i) -> HTML w i
router_ = router []
