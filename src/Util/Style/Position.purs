module Util.Style.Position where

import Proem hiding (bottom, top)
import CSS (CSS) as CSS
import CSS (absolute, bottom, fixed, fromString, left, pct, position, relative, rem, right, top)
import CSS.Common (browsers)
import CSS.Property (Value(..))
import Util.Style.Base (raw)
import Util.Style.Transform (transformTranslatePct)

positionAbsolute :: CSS.CSS
positionAbsolute = position absolute

positionRelative :: CSS.CSS
positionRelative = position relative

positionFixed :: CSS.CSS
positionFixed = position fixed

positionSticky :: CSS.CSS
positionSticky = raw "position" (Value $ browsers <> fromString "sticky")

topRem :: Number -> CSS.CSS
topRem t = top (rem t)

topPct :: Number -> CSS.CSS
topPct t = top (pct t)

leftRem :: Number -> CSS.CSS
leftRem l = left (rem l)

leftPct :: Number -> CSS.CSS
leftPct l = left (pct l)

bottomRem :: Number -> CSS.CSS
bottomRem b = bottom (rem b)

bottomPct :: Number -> CSS.CSS
bottomPct b = bottom (pct b)

rightRem :: Number -> CSS.CSS
rightRem r = right (rem r)

rightPct :: Number -> CSS.CSS
rightPct r = right (pct r)

top0 :: CSS.CSS
top0 = topRem 0.0

topPct50 :: CSS.CSS
topPct50 = topPct 50.0

topPct100 :: CSS.CSS
topPct100 = topPct 100.0

topAuto :: CSS.CSS
topAuto = raw "top" "auto"

left0 :: CSS.CSS
left0 = leftRem 0.0

leftPct50 :: CSS.CSS
leftPct50 = leftPct 50.0

leftPct100 :: CSS.CSS
leftPct100 = leftPct 100.0

leftAuto :: CSS.CSS
leftAuto = raw "left" "auto"

bottom0 :: CSS.CSS
bottom0 = bottomRem 0.0

bottomPct50 :: CSS.CSS
bottomPct50 = bottomPct 50.0

bottomPct100 :: CSS.CSS
bottomPct100 = bottomPct 100.0

bottomAuto :: CSS.CSS
bottomAuto = raw "bottom" "auto"

right0 :: CSS.CSS
right0 = rightRem 0.0

rightPct50 :: CSS.CSS
rightPct50 = rightPct 50.0

rightPct100 :: CSS.CSS
rightPct100 = rightPct 100.0

rightAuto :: CSS.CSS
rightAuto = raw "right" "auto"

positionAbsoluteOnlyTranslatePct :: Number -> Number -> CSS.CSS
positionAbsoluteOnlyTranslatePct x y = do
  positionAbsolute
  leftAuto
  rightAuto
  topAuto
  bottomAuto
  transformTranslatePct x y
