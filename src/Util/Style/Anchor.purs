module Util.Style.Anchor where

import Proem hiding (bottom, top)
import CSS (CSS) as CSS
import CSS (bottom, left, pct, rem, right, top)
import CSS.Size (calcSum)
import Util.Style.Position (positionAbsoluteOnlyTranslatePct)

data AnchorPosition
  = TopLeftToTopLeft
  | TopLeftToTopCenter
  | TopLeftToTopRight
  | TopLeftToCenterLeft
  | TopLeftToCenter
  | TopLeftToCenterRight
  | TopLeftToBottomLeft
  | TopLeftToBottomCenter
  | TopLeftToBottomRight
  | TopCenterToTopLeft
  | TopCenterToTopCenter
  | TopCenterToTopRight
  | TopCenterToCenterLeft
  | TopCenterToCenter
  | TopCenterToCenterRight
  | TopCenterToBottomLeft
  | TopCenterToBottomCenter
  | TopCenterToBottomRight
  | TopRightToTopLeft
  | TopRightToTopCenter
  | TopRightToTopRight
  | TopRightToCenterLeft
  | TopRightToCenter
  | TopRightToCenterRight
  | TopRightToBottomLeft
  | TopRightToBottomCenter
  | TopRightToBottomRight
  | CenterLeftToTopLeft
  | CenterLeftToTopCenter
  | CenterLeftToTopRight
  | CenterLeftToCenterLeft
  | CenterLeftToCenter
  | CenterLeftToCenterRight
  | CenterLeftToBottomLeft
  | CenterLeftToBottomCenter
  | CenterLeftToBottomRight
  | CenterToTopLeft
  | CenterToTopCenter
  | CenterToTopRight
  | CenterToCenterLeft
  | CenterToCenter
  | CenterToCenterRight
  | CenterToBottomLeft
  | CenterToBottomCenter
  | CenterToBottomRight
  | CenterRightToTopLeft
  | CenterRightToTopCenter
  | CenterRightToTopRight
  | CenterRightToCenterLeft
  | CenterRightToCenter
  | CenterRightToCenterRight
  | CenterRightToBottomLeft
  | CenterRightToBottomCenter
  | CenterRightToBottomRight
  | BottomLeftToTopLeft
  | BottomLeftToTopCenter
  | BottomLeftToTopRight
  | BottomLeftToCenterLeft
  | BottomLeftToCenter
  | BottomLeftToCenterRight
  | BottomLeftToBottomLeft
  | BottomLeftToBottomCenter
  | BottomLeftToBottomRight
  | BottomCenterToTopLeft
  | BottomCenterToTopCenter
  | BottomCenterToTopRight
  | BottomCenterToCenterLeft
  | BottomCenterToCenter
  | BottomCenterToCenterRight
  | BottomCenterToBottomLeft
  | BottomCenterToBottomCenter
  | BottomCenterToBottomRight
  | BottomRightToTopLeft
  | BottomRightToTopCenter
  | BottomRightToTopRight
  | BottomRightToCenterLeft
  | BottomRightToCenter
  | BottomRightToCenterRight
  | BottomRightToBottomLeft
  | BottomRightToBottomCenter
  | BottomRightToBottomRight

topLeftToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topLeftToTopLeft :: CSS.CSS
topLeftToTopLeft = topLeftToTopLeftWithRemDelta 0.0 0.0

topCenterToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topCenterToTopLeft :: CSS.CSS
topCenterToTopLeft = topCenterToTopLeftWithRemDelta 0.0 0.0

topRightToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
topRightToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topRightToTopLeft :: CSS.CSS
topRightToTopLeft = topRightToTopLeftWithRemDelta 0.0 0.0

centerLeftToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerLeftToTopLeft :: CSS.CSS
centerLeftToTopLeft = centerLeftToTopLeftWithRemDelta 0.0 0.0

centerToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerToTopLeft :: CSS.CSS
centerToTopLeft = centerToTopLeftWithRemDelta 0.0 0.0

centerRightToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerRightToTopLeft :: CSS.CSS
centerRightToTopLeft = centerRightToTopLeftWithRemDelta 0.0 0.0

bottomLeftToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomLeftToTopLeft :: CSS.CSS
bottomLeftToTopLeft = bottomLeftToTopLeftWithRemDelta 0.0 0.0

bottomCenterToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomCenterToTopLeft :: CSS.CSS
bottomCenterToTopLeft = bottomCenterToTopLeftWithRemDelta 0.0 0.0

bottomRightToTopLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToTopLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomRightToTopLeft :: CSS.CSS
bottomRightToTopLeft = bottomRightToTopLeftWithRemDelta 0.0 0.0

topLeftToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topLeftToTopCenter :: CSS.CSS
topLeftToTopCenter = topLeftToTopCenterWithRemDelta 0.0 0.0

topCenterToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topCenterToTopCenter :: CSS.CSS
topCenterToTopCenter = topCenterToTopCenterWithRemDelta 0.0 0.0

topRightToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
topRightToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topRightToTopCenter :: CSS.CSS
topRightToTopCenter = topRightToTopCenterWithRemDelta 0.0 0.0

centerLeftToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerLeftToTopCenter :: CSS.CSS
centerLeftToTopCenter = centerLeftToTopCenterWithRemDelta 0.0 0.0

centerToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerToTopCenter :: CSS.CSS
centerToTopCenter = centerToTopCenterWithRemDelta 0.0 0.0

centerRightToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerRightToTopCenter :: CSS.CSS
centerRightToTopCenter = centerRightToTopCenterWithRemDelta 0.0 0.0

bottomLeftToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomLeftToTopCenter :: CSS.CSS
bottomLeftToTopCenter = bottomLeftToTopCenterWithRemDelta 0.0 0.0

bottomCenterToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomCenterToTopCenter :: CSS.CSS
bottomCenterToTopCenter = bottomCenterToTopCenterWithRemDelta 0.0 0.0

bottomRightToTopCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToTopCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomRightToTopCenter :: CSS.CSS
bottomRightToTopCenter = bottomRightToTopCenterWithRemDelta 0.0 0.0

topLeftToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topLeftToTopRight :: CSS.CSS
topLeftToTopRight = topLeftToTopRightWithRemDelta 0.0 0.0

topCenterToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topCenterToTopRight :: CSS.CSS
topCenterToTopRight = topCenterToTopRightWithRemDelta 0.0 0.0

topRightToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
topRightToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

topRightToTopRight :: CSS.CSS
topRightToTopRight = topRightToTopRightWithRemDelta 0.0 0.0

centerLeftToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerLeftToTopRight :: CSS.CSS
centerLeftToTopRight = centerLeftToTopRightWithRemDelta 0.0 0.0

centerToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
centerToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerToTopRight :: CSS.CSS
centerToTopRight = centerToTopRightWithRemDelta 0.0 0.0

centerRightToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 0.0) (rem y)

centerRightToTopRight :: CSS.CSS
centerRightToTopRight = centerRightToTopRightWithRemDelta 0.0 0.0

bottomLeftToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomLeftToTopRight :: CSS.CSS
bottomLeftToTopRight = bottomLeftToTopRightWithRemDelta 0.0 0.0

bottomCenterToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomCenterToTopRight :: CSS.CSS
bottomCenterToTopRight = bottomCenterToTopRightWithRemDelta 0.0 0.0

bottomRightToTopRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToTopRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomRightToTopRight :: CSS.CSS
bottomRightToTopRight = bottomRightToTopRightWithRemDelta 0.0 0.0

topLeftToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topLeftToCenterLeft :: CSS.CSS
topLeftToCenterLeft = topLeftToCenterLeftWithRemDelta 0.0 0.0

topCenterToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topCenterToCenterLeft :: CSS.CSS
topCenterToCenterLeft = topCenterToCenterLeftWithRemDelta 0.0 0.0

topRightToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
topRightToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topRightToCenterLeft :: CSS.CSS
topRightToCenterLeft = topRightToCenterLeftWithRemDelta 0.0 0.0

centerLeftToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerLeftToCenterLeft :: CSS.CSS
centerLeftToCenterLeft = centerLeftToCenterLeftWithRemDelta 0.0 0.0

centerToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerToCenterLeft :: CSS.CSS
centerToCenterLeft = centerToCenterLeftWithRemDelta 0.0 0.0

centerRightToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerRightToCenterLeft :: CSS.CSS
centerRightToCenterLeft = centerRightToCenterLeftWithRemDelta 0.0 0.0

bottomLeftToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomLeftToCenterLeft :: CSS.CSS
bottomLeftToCenterLeft = bottomLeftToCenterLeftWithRemDelta 0.0 0.0

bottomCenterToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomCenterToCenterLeft :: CSS.CSS
bottomCenterToCenterLeft = bottomCenterToCenterLeftWithRemDelta 0.0 0.0

bottomRightToCenterLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToCenterLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomRightToCenterLeft :: CSS.CSS
bottomRightToCenterLeft = bottomRightToCenterLeftWithRemDelta 0.0 0.0

topLeftToCenterWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topLeftToCenter :: CSS.CSS
topLeftToCenter = topLeftToCenterWithRemDelta 0.0 0.0

topCenterToCenterWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topCenterToCenter :: CSS.CSS
topCenterToCenter = topCenterToCenterWithRemDelta 0.0 0.0

topRightToCenterWithRemDelta :: Number -> Number -> CSS.CSS
topRightToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topRightToCenter :: CSS.CSS
topRightToCenter = topRightToCenterWithRemDelta 0.0 0.0

centerLeftToCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerLeftToCenter :: CSS.CSS
centerLeftToCenter = centerLeftToCenterWithRemDelta 0.0 0.0

centerToCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerToCenter :: CSS.CSS
centerToCenter = centerToCenterWithRemDelta 0.0 0.0

centerRightToCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 50.0) (rem $ -1.0 * x)
  top $ calcSum (pct 50.0) (rem y)

centerRightToCenter :: CSS.CSS
centerRightToCenter = centerRightToCenterWithRemDelta 0.0 0.0

bottomLeftToCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomLeftToCenter :: CSS.CSS
bottomLeftToCenter = bottomLeftToCenterWithRemDelta 0.0 0.0

bottomCenterToCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomCenterToCenter :: CSS.CSS
bottomCenterToCenter = bottomCenterToCenterWithRemDelta 0.0 0.0

bottomRightToCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomRightToCenter :: CSS.CSS
bottomRightToCenter = bottomRightToCenterWithRemDelta 0.0 0.0

topLeftToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topLeftToCenterRight :: CSS.CSS
topLeftToCenterRight = topLeftToCenterRightWithRemDelta 0.0 0.0

topCenterToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topCenterToCenterRight :: CSS.CSS
topCenterToCenterRight = topCenterToCenterRightWithRemDelta 0.0 0.0

topRightToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
topRightToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

topRightToCenterRight :: CSS.CSS
topRightToCenterRight = topRightToCenterRightWithRemDelta 0.0 0.0

centerLeftToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerLeftToCenterRight :: CSS.CSS
centerLeftToCenterRight = centerLeftToCenterRightWithRemDelta 0.0 0.0

centerToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
centerToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerToCenterRight :: CSS.CSS
centerToCenterRight = centerToCenterRightWithRemDelta 0.0 0.0

centerRightToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 50.0) (rem y)

centerRightToCenterRight :: CSS.CSS
centerRightToCenterRight = centerRightToCenterRightWithRemDelta 0.0 0.0

bottomLeftToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomLeftToCenterRight :: CSS.CSS
bottomLeftToCenterRight = bottomLeftToCenterRightWithRemDelta 0.0 0.0

bottomCenterToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomCenterToCenterRight :: CSS.CSS
bottomCenterToCenterRight = bottomCenterToCenterRightWithRemDelta 0.0 0.0

bottomRightToCenterRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToCenterRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 100.0) (rem y)

bottomRightToCenterRight :: CSS.CSS
bottomRightToCenterRight = bottomRightToCenterRightWithRemDelta 0.0 0.0

topLeftToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topLeftToBottomLeft :: CSS.CSS
topLeftToBottomLeft = topLeftToBottomLeftWithRemDelta 0.0 0.0

topCenterToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topCenterToBottomLeft :: CSS.CSS
topCenterToBottomLeft = topCenterToBottomLeftWithRemDelta 0.0 0.0

topRightToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
topRightToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topRightToBottomLeft :: CSS.CSS
topRightToBottomLeft = topRightToBottomLeftWithRemDelta 0.0 0.0

centerLeftToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerLeftToBottomLeft :: CSS.CSS
centerLeftToBottomLeft = centerLeftToBottomLeftWithRemDelta 0.0 0.0

centerToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerToBottomLeft :: CSS.CSS
centerToBottomLeft = centerToBottomLeftWithRemDelta 0.0 0.0

centerRightToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerRightToBottomLeft :: CSS.CSS
centerRightToBottomLeft = centerRightToBottomLeftWithRemDelta 0.0 0.0

bottomLeftToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomLeftToBottomLeft :: CSS.CSS
bottomLeftToBottomLeft = bottomLeftToBottomLeftWithRemDelta 0.0 0.0

bottomCenterToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomCenterToBottomLeft :: CSS.CSS
bottomCenterToBottomLeft = bottomCenterToBottomLeftWithRemDelta 0.0 0.0

bottomRightToBottomLeftWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToBottomLeftWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomRightToBottomLeft :: CSS.CSS
bottomRightToBottomLeft = bottomRightToBottomLeftWithRemDelta 0.0 0.0

topLeftToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topLeftToBottomCenter :: CSS.CSS
topLeftToBottomCenter = topLeftToBottomCenterWithRemDelta 0.0 0.0

topCenterToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topCenterToBottomCenter :: CSS.CSS
topCenterToBottomCenter = topCenterToBottomCenterWithRemDelta 0.0 0.0

topRightToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
topRightToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topRightToBottomCenter :: CSS.CSS
topRightToBottomCenter = topRightToBottomCenterWithRemDelta 0.0 0.0

centerLeftToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerLeftToBottomCenter :: CSS.CSS
centerLeftToBottomCenter = centerLeftToBottomCenterWithRemDelta 0.0 0.0

centerToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerToBottomCenter :: CSS.CSS
centerToBottomCenter = centerToBottomCenterWithRemDelta 0.0 0.0

centerRightToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 50.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerRightToBottomCenter :: CSS.CSS
centerRightToBottomCenter = centerRightToBottomCenterWithRemDelta 0.0 0.0

bottomLeftToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomLeftToBottomCenter :: CSS.CSS
bottomLeftToBottomCenter = bottomLeftToBottomCenterWithRemDelta 0.0 0.0

bottomCenterToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomCenterToBottomCenter :: CSS.CSS
bottomCenterToBottomCenter = bottomCenterToBottomCenterWithRemDelta 0.0 0.0

bottomRightToBottomCenterWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToBottomCenterWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 50.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomRightToBottomCenter :: CSS.CSS
bottomRightToBottomCenter = bottomRightToBottomCenterWithRemDelta 0.0 0.0

topLeftToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
topLeftToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topLeftToBottomRight :: CSS.CSS
topLeftToBottomRight = topLeftToBottomRightWithRemDelta 0.0 0.0

topCenterToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
topCenterToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topCenterToBottomRight :: CSS.CSS
topCenterToBottomRight = topCenterToBottomRightWithRemDelta 0.0 0.0

topRightToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
topRightToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

topRightToBottomRight :: CSS.CSS
topRightToBottomRight = topRightToBottomRightWithRemDelta 0.0 0.0

centerLeftToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
centerLeftToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerLeftToBottomRight :: CSS.CSS
centerLeftToBottomRight = centerLeftToBottomRightWithRemDelta 0.0 0.0

centerToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
centerToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) (-50.0)
  left $ calcSum (pct 100.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerToBottomRight :: CSS.CSS
centerToBottomRight = centerToBottomRightWithRemDelta 0.0 0.0

centerRightToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
centerRightToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 (-50.0)
  right $ calcSum (pct 0.0) (rem x)
  top $ calcSum (pct 100.0) (rem y)

centerRightToBottomRight :: CSS.CSS
centerRightToBottomRight = centerRightToBottomRightWithRemDelta 0.0 0.0

bottomLeftToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomLeftToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  left $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomLeftToBottomRight :: CSS.CSS
bottomLeftToBottomRight = bottomLeftToBottomRightWithRemDelta 0.0 0.0

bottomCenterToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomCenterToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct (-50.0) 0.0
  left $ calcSum (pct 100.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomCenterToBottomRight :: CSS.CSS
bottomCenterToBottomRight = bottomCenterToBottomRightWithRemDelta 0.0 0.0

bottomRightToBottomRightWithRemDelta :: Number -> Number -> CSS.CSS
bottomRightToBottomRightWithRemDelta x y = do
  positionAbsoluteOnlyTranslatePct 0.0 0.0
  right $ calcSum (pct 0.0) (rem x)
  bottom $ calcSum (pct 0.0) (rem y)

bottomRightToBottomRight :: CSS.CSS
bottomRightToBottomRight = bottomRightToBottomRightWithRemDelta 0.0 0.0

anchorPositionToCss :: AnchorPosition -> CSS.CSS
anchorPositionToCss = case _ of
  TopLeftToTopLeft -> topLeftToTopLeft
  TopLeftToTopCenter -> topLeftToTopCenter
  TopLeftToTopRight -> topLeftToTopRight
  TopLeftToCenterLeft -> topLeftToCenterLeft
  TopLeftToCenter -> topLeftToCenter
  TopLeftToCenterRight -> topLeftToCenterRight
  TopLeftToBottomLeft -> topLeftToBottomLeft
  TopLeftToBottomCenter -> topLeftToBottomCenter
  TopLeftToBottomRight -> topLeftToBottomRight
  TopCenterToTopLeft -> topCenterToTopLeft
  TopCenterToTopCenter -> topCenterToTopCenter
  TopCenterToTopRight -> topCenterToTopRight
  TopCenterToCenterLeft -> topCenterToCenterLeft
  TopCenterToCenter -> topCenterToCenter
  TopCenterToCenterRight -> topCenterToCenterRight
  TopCenterToBottomLeft -> topCenterToBottomLeft
  TopCenterToBottomCenter -> topCenterToBottomCenter
  TopCenterToBottomRight -> topCenterToBottomRight
  TopRightToTopLeft -> topRightToTopLeft
  TopRightToTopCenter -> topRightToTopCenter
  TopRightToTopRight -> topRightToTopRight
  TopRightToCenterLeft -> topRightToCenterLeft
  TopRightToCenter -> topRightToCenter
  TopRightToCenterRight -> topRightToCenterRight
  TopRightToBottomLeft -> topRightToBottomLeft
  TopRightToBottomCenter -> topRightToBottomCenter
  TopRightToBottomRight -> topRightToBottomRight
  CenterLeftToTopLeft -> centerLeftToTopLeft
  CenterLeftToTopCenter -> centerLeftToTopCenter
  CenterLeftToTopRight -> centerLeftToTopRight
  CenterLeftToCenterLeft -> centerLeftToCenterLeft
  CenterLeftToCenter -> centerLeftToCenter
  CenterLeftToCenterRight -> centerLeftToCenterRight
  CenterLeftToBottomLeft -> centerLeftToBottomLeft
  CenterLeftToBottomCenter -> centerLeftToBottomCenter
  CenterLeftToBottomRight -> centerLeftToBottomRight
  CenterToTopLeft -> centerToTopLeft
  CenterToTopCenter -> centerToTopCenter
  CenterToTopRight -> centerToTopRight
  CenterToCenterLeft -> centerToCenterLeft
  CenterToCenter -> centerToCenter
  CenterToCenterRight -> centerToCenterRight
  CenterToBottomLeft -> centerToBottomLeft
  CenterToBottomCenter -> centerToBottomCenter
  CenterToBottomRight -> centerToBottomRight
  CenterRightToTopLeft -> centerRightToTopLeft
  CenterRightToTopCenter -> centerRightToTopCenter
  CenterRightToTopRight -> centerRightToTopRight
  CenterRightToCenterLeft -> centerRightToCenterLeft
  CenterRightToCenter -> centerRightToCenter
  CenterRightToCenterRight -> centerRightToCenterRight
  CenterRightToBottomLeft -> centerRightToBottomLeft
  CenterRightToBottomCenter -> centerRightToBottomCenter
  CenterRightToBottomRight -> centerRightToBottomRight
  BottomLeftToTopLeft -> bottomLeftToTopLeft
  BottomLeftToTopCenter -> bottomLeftToTopCenter
  BottomLeftToTopRight -> bottomLeftToTopRight
  BottomLeftToCenterLeft -> bottomLeftToCenterLeft
  BottomLeftToCenter -> bottomLeftToCenter
  BottomLeftToCenterRight -> bottomLeftToCenterRight
  BottomLeftToBottomLeft -> bottomLeftToBottomLeft
  BottomLeftToBottomCenter -> bottomLeftToBottomCenter
  BottomLeftToBottomRight -> bottomLeftToBottomRight
  BottomCenterToTopLeft -> bottomCenterToTopLeft
  BottomCenterToTopCenter -> bottomCenterToTopCenter
  BottomCenterToTopRight -> bottomCenterToTopRight
  BottomCenterToCenterLeft -> bottomCenterToCenterLeft
  BottomCenterToCenter -> bottomCenterToCenter
  BottomCenterToCenterRight -> bottomCenterToCenterRight
  BottomCenterToBottomLeft -> bottomCenterToBottomLeft
  BottomCenterToBottomCenter -> bottomCenterToBottomCenter
  BottomCenterToBottomRight -> bottomCenterToBottomRight
  BottomRightToTopLeft -> bottomRightToTopLeft
  BottomRightToTopCenter -> bottomRightToTopCenter
  BottomRightToTopRight -> bottomRightToTopRight
  BottomRightToCenterLeft -> bottomRightToCenterLeft
  BottomRightToCenter -> bottomRightToCenter
  BottomRightToCenterRight -> bottomRightToCenterRight
  BottomRightToBottomLeft -> bottomRightToBottomLeft
  BottomRightToBottomCenter -> bottomRightToBottomCenter
  BottomRightToBottomRight -> bottomRightToBottomRight
