module Util.Style.Effect where

import Proem hiding (bottom, top)
import CSS (CSS, Size) as CSS
import CSS (Stroke, StyleM, angular, animation, backgroundColor, backgroundImage, backgroundRepeat, backgroundSize, borderColor, borderRadius, by, color, cursor, deg, forwards, fromString, infinite, linear, linearGradient, noRepeat, normalAnimationDirection, pct, rem, rgba, sec, toHexString, value)
import CSS.Color (Color)
import CSS.Cursor (pointer)
import Data.Tuple.Nested ((/\))
import Util.Style.Base (raw)
import Util.Style.Classname (hash9)
import Util.Style.Color (transparent)
import Util.Style.Typography (userSelectNone)
import Util.Power (isPowerful)

outlineNone :: CSS.CSS
outlineNone = raw "outline" "none"

loadingShimmerAnimationId :: String
loadingShimmerAnimationId = hash9 "loadingShimmerAnimation"

loadingShimmerWidth :: Number
loadingShimmerWidth = 30.0

type LoadingOpt =
  { darker :: Boolean
  , opacity :: Number
  , shimmerOpacity :: Number
  }

defaultLoadingOpt :: LoadingOpt
defaultLoadingOpt =
  { darker: true
  , opacity: 0.2
  , shimmerOpacity: 0.4
  }

defaultLoading :: StyleM Ɩ
defaultLoading = loading defaultLoadingOpt

loading :: LoadingOpt -> StyleM Ɩ
loading { darker, opacity: opacity', shimmerOpacity } = do
  let bgHex = darker ? 0 ↔ 255

  backgroundColor $ rgba bgHex bgHex bgHex opacity'
  borderColor transparent
  color transparent
  userSelectNone
  borderRadiusRem1 0.4
  when isPowerful do
    backgroundImage $ linearGradient (angular $ deg 90.0)
      [ transparent /\ pct 0.0
      , rgba 255 255 255 shimmerOpacity /\ pct 50.0
      , transparent /\ pct 100.0
      ]
    backgroundSize $ by (rem loadingShimmerWidth) (pct 100.0)
    backgroundRepeat noRepeat
    animation
      (fromString loadingShimmerAnimationId)
      (sec 0.7)
      linear
      (sec 0.0)
      infinite
      normalAnimationDirection
      forwards

cursorPointer :: CSS.CSS
cursorPointer = cursor pointer

pointerEventsNone :: CSS.CSS
pointerEventsNone = raw "pointer-events" "none"

backdropFilter :: String -> CSS.CSS
backdropFilter f = raw "backdrop-filter" f

filter :: String -> CSS.CSS
filter f = raw "filter" f

whiteGlassBackground :: CSS.CSS
whiteGlassBackground = backgroundColor $ rgba 255 255 255 0.7

mixBlendMode :: String -> CSS.CSS
mixBlendMode = raw "mix-blend-mode"

mixBlendModeScreen :: CSS.CSS
mixBlendModeScreen = mixBlendMode "screen"

boxShadow :: Number -> Number -> Number -> Color -> CSS.CSS
boxShadow x y blur color = do
  let
    s =
      show x
        <> "rem "
        <> show y
        <> "rem "
        <> show blur
        <> "rem "
        <> toHexString color
  raw "box-shadow" s

fill :: Color -> CSS.CSS
fill c = raw "fill" $ toHexString c

borderRadiusRem4 :: Number -> Number -> Number -> Number -> CSS.CSS
borderRadiusRem4 tl tr br bl = borderRadius (rem tl) (rem tr) (rem br) (rem bl)

borderRadiusRem1 :: Number -> CSS.CSS
borderRadiusRem1 r = borderRadiusRem4 r r r r

borderRadiusPct4 :: Number -> Number -> Number -> Number -> CSS.CSS
borderRadiusPct4 tl tr br bl = borderRadius (pct tl) (pct tr) (pct br) (pct bl)

borderRadiusPct1 :: Number -> CSS.CSS
borderRadiusPct1 r = borderRadiusPct4 r r r r

borderRadiusPct50 :: CSS.CSS
borderRadiusPct50 = borderRadiusPct1 50.0

borderRadius1 :: ∀ a. CSS.Size a -> CSS.CSS
borderRadius1 b = borderRadius b b b b

borderWidth1 :: Number -> CSS.CSS
borderWidth1 w = raw "border-width" $ show w <> "rem"

borderStyle :: Stroke -> CSS.CSS
borderStyle stroke = raw "border-style" (value stroke)

borderBottomWidth :: Number -> CSS.CSS
borderBottomWidth w = raw "border-bottom-width" $ show w <> "rem"

borderTopWidth :: Number -> CSS.CSS
borderTopWidth w = raw "border-top-width" $ show w <> "rem"

borderLeftWidth :: Number -> CSS.CSS
borderLeftWidth w = raw "border-left-width" $ show w <> "rem"

borderRightWidth :: Number -> CSS.CSS
borderRightWidth w = raw "border-right-width" $ show w <> "rem"
