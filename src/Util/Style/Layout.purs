module Util.Style.Layout where

import Proem hiding (bottom, top)
import CSS (CSS, displayNone, flexWrap, marginBottom, marginLeft, marginRight, marginTop, paddingBottom, paddingLeft, paddingRight, paddingTop) as CSS
import CSS (alignItems, display, flex, flexGrow, height, inlineBlock, justifyContent, margin, maxHeight, maxWidth, minHeight, minWidth, padding, pct, rem, width, wrap)
import CSS.Common as CSSC
import CSS.Overflow (hidden, overflow, scroll)
import CSS.Overflow (overflowAuto) as CSS
import Util.Style.Base (raw)

displayNone :: CSS.CSS
displayNone = display CSS.displayNone

overflowAuto :: CSS.CSS
overflowAuto = overflow CSS.overflowAuto

overflowHidden :: CSS.CSS
overflowHidden = overflow hidden

overflowScroll :: CSS.CSS
overflowScroll = overflow scroll

overflowXHidden :: CSS.CSS
overflowXHidden = raw "overflow-x" "hidden"

overflowYAuto :: CSS.CSS
overflowYAuto = raw "overflow-y" "auto"

overflowScrollingTouch :: CSS.CSS
overflowScrollingTouch = raw "overflow-scrolling" "touch"

flexWrap :: CSS.CSS
flexWrap = CSS.flexWrap wrap

flexGrow1 :: CSS.CSS
flexGrow1 = flexGrow 1.0

displayInlineBlock :: CSS.CSS
displayInlineBlock = display inlineBlock

displayFlex :: CSS.CSS
displayFlex = display flex

justifyContentCenter :: CSS.CSS
justifyContentCenter = justifyContent CSSC.center

alignItemsCenter :: CSS.CSS
alignItemsCenter = alignItems CSSC.center

gapPct :: Number -> CSS.CSS
gapPct p = raw "gap" (show p <> "%")

gapRem :: Number -> CSS.CSS
gapRem r = raw "gap" (show r <> "rem")

visibilityVisible :: CSS.CSS
visibilityVisible = raw "visibility" "visible"

visibilityHidden :: CSS.CSS
visibilityHidden = raw "visibility" "hidden"

boxSizingBorderBox :: CSS.CSS
boxSizingBorderBox = raw "box-sizing" "border-box"

gridTemplateColumns :: String -> CSS.CSS
gridTemplateColumns = raw "grid-template-columns"

aspectRatio :: Int -> Int -> CSS.CSS
aspectRatio w h = raw "aspect-ratio" (show w <> " / " <> show h)

widthRem :: Number -> CSS.CSS
widthRem w = width (rem w)

widthPct :: Number -> CSS.CSS
widthPct w = width (pct w)

widthPct100 :: CSS.CSS
widthPct100 = widthPct 100.0

widthAuto :: CSS.CSS
widthAuto = raw "width" "auto"

width0 :: CSS.CSS
width0 = widthRem 0.0

minWidthRem :: Number -> CSS.CSS
minWidthRem w = minWidth (rem w)

minWidthPct :: Number -> CSS.CSS
minWidthPct w = minWidth (pct w)

minWidthPct100 :: CSS.CSS
minWidthPct100 = minWidthPct 100.0

maxWidthRem :: Number -> CSS.CSS
maxWidthRem w = maxWidth (rem w)

maxWidthPct :: Number -> CSS.CSS
maxWidthPct w = maxWidth (pct w)

maxWidthPct100 :: CSS.CSS
maxWidthPct100 = maxWidthPct 100.0

heightAuto :: CSS.CSS
heightAuto = raw "height" "auto"

height0 :: CSS.CSS
height0 = heightRem 0.0

heightRem :: Number -> CSS.CSS
heightRem h = height (rem h)

heightPct :: Number -> CSS.CSS
heightPct h = height (pct h)

heightPct100 :: CSS.CSS
heightPct100 = heightPct 100.0

minHeightRem :: Number -> CSS.CSS
minHeightRem h = minHeight (rem h)

minHeightPct :: Number -> CSS.CSS
minHeightPct h = minHeight (pct h)

maxHeightRem :: Number -> CSS.CSS
maxHeightRem h = maxHeight (rem h)

maxHeightPct :: Number -> CSS.CSS
maxHeightPct h = maxHeight (pct h)

padding0 :: CSS.CSS
padding0 = padding1 0.0

padding4 :: Number -> Number -> Number -> Number -> CSS.CSS
padding4 t r b l = padding (rem t) (rem r) (rem b) (rem l)

padding1 :: Number -> CSS.CSS
padding1 p = padding4 p p p p

padding2 :: Number -> Number -> CSS.CSS
padding2 v h = padding4 v h v h

paddingLeft :: Number -> CSS.CSS
paddingLeft p = CSS.paddingLeft (rem p)

paddingRight :: Number -> CSS.CSS
paddingRight p = CSS.paddingRight (rem p)

paddingBottom :: Number -> CSS.CSS
paddingBottom p = CSS.paddingBottom (rem p)

paddingTop :: Number -> CSS.CSS
paddingTop p = CSS.paddingTop (rem p)

margin0 :: CSS.CSS
margin0 = margin1 0.0

margin4 :: Number -> Number -> Number -> Number -> CSS.CSS
margin4 t r b l = margin (rem t) (rem r) (rem b) (rem l)

margin1 :: Number -> CSS.CSS
margin1 m = margin4 m m m m

margin2 :: Number -> Number -> CSS.CSS
margin2 v h = margin4 v h v h

marginLeft :: Number -> CSS.CSS
marginLeft m = CSS.marginLeft (rem m)

marginRight :: Number -> CSS.CSS
marginRight m = CSS.marginRight (rem m)

marginTop :: Number -> CSS.CSS
marginTop m = CSS.marginTop (rem m)

marginBottom :: Number -> CSS.CSS
marginBottom m = CSS.marginBottom (rem m)
