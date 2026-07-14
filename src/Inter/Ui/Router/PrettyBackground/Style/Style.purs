module Inter.Ui.Router.PrettyBackground.Style.Style
  ( prettyBackground
  , prettyBackground_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (top, div)

import CSS (angular, background, deg, forwards, fromString, infinite, keyframes, linear, linearGradient, minHeight, normalAnimationDirection, pct, rgba, rotate, sec, transforms, vh, zIndex)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Data.NonEmpty ((:|))
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested ((/\))
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass, inferAnimationId)
import Util.Style.Position (left0, leftPct, positionAbsolute, positionFixed, top0, topPct)
import Util.Style.Layout (displayFlex, heightPct, overflowHidden, widthPct, widthPct100)
import Util.Style.Typography (content)
import Util.Power (isPowerful)
import Util.Style.Selector (before, (.?), (:&))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.PrettyBackground.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

animationId :: String
animationId = inferAnimationId staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionFixed
    top0
    left0
    widthPct100
    minHeight (vh 100.0)
    displayFlex
    overflowHidden
    zIndex (-1)
    when (not isPowerful) do
      background $ linearGradient (angular $ deg 225.0)
        [ Tuple (rgba 255 250 248 1.0) (pct 25.0)
        , Tuple (rgba 250 232 225 1.0) (pct 50.0)
        , Tuple (rgba 246 195 186 1.0) (pct 75.0)
        ]

    when isPowerful $ before :& do
      content ""
      positionAbsolute
      topPct (-100.0)
      leftPct (-100.0)
      widthPct 300.0
      heightPct 300.0
      zIndex (-1)

      background $ linearGradient (angular $ deg 45.0)
        [ Tuple (rgba 255 250 248 1.0) (pct 25.0)
        , Tuple (rgba 250 232 225 1.0) (pct 50.0)
        , Tuple (rgba 246 195 186 1.0) (pct 75.0)
        ]

      CSS.animation
        (fromString animationId)
        (sec 15.0)
        linear
        (sec 0.0)
        infinite
        normalAnimationDirection
        forwards

  keyframes animationId
    ( 0.0 /\ transforms [ rotate (deg 0.0) ]
        :| [ 100.0 /\ transforms [ rotate (deg 360.0) ] ]
    )

prettyBackground :: ∀ w i. Node HTMLdiv w i
prettyBackground props = div ([ class_ staticClass ] <> props)

prettyBackground_ :: ∀ w i. Array (HTML w i) -> HTML w i
prettyBackground_ = prettyBackground []
