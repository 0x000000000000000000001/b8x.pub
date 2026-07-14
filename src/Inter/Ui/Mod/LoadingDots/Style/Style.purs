module Inter.Ui.Mod.LoadingDots.Style.Style
  ( loadingDots_
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (key, transform)
import CSS as CSS
import CSS.String (fromString)
import CSS.Transform (scale)
import Halogen.HTML (HTML, div)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Layout (displayFlex, alignItemsCenter, justifyContentCenter)
import Util.Style.Selector ((.?))
import CSS.Geometry (margin, minHeight)
import CSS.Border (borderRadius)
import CSS.Size (rem, pct)
import CSS.Color (black)
import CSS.Background (backgroundColor)
import Halogen.HTML.Properties as HP
import Halogen.HTML.Core (AttrName(..))
import Inter.Ui.Mod.LoadingDots.Type (Input, Color(..))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.LoadingDots.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

dotClass :: String
dotClass = staticClass <> "-dot"

staticStyle :: CSS.CSS
staticStyle = do
  CSS.keyframesFromTo "loading-dots-scale"
    (transform (scale 0.5 0.5))
    (transform (scale 1.2 1.2))

  staticClass .? do
    displayFlex
    alignItemsCenter
    justifyContentCenter
    minHeight (rem 2.0)

  ("." <> dotClass) .? do
    margin (rem 0.0) (rem 0.2) (rem 0.0) (rem 0.2)
    borderRadius (pct 50.0) (pct 50.0) (pct 50.0) (pct 50.0)
    backgroundColor black
    key (fromString "animation-name") "loading-dots-scale"
    key (fromString "animation-duration") "600ms"
    key (fromString "animation-iteration-count") "infinite"
    key (fromString "animation-direction") "alternate"
    key (fromString "animation-timing-function") "ease-in-out"
    
  ("." <> dotClass <> ":nth-child(1)") .? do
    key (fromString "animation-delay") "0ms"

  ("." <> dotClass <> ":nth-child(2)") .? do
    key (fromString "animation-delay") "200ms"

  ("." <> dotClass <> ":nth-child(3)") .? do
    key (fromString "animation-delay") "400ms"

loadingDots_ :: ∀ w i. Input -> HTML w i
loadingDots_ { opacity, color, sizeRem } = 
  let
    bg = case color of
      Black -> "black"
      White -> "white"
    sizeStr = show sizeRem <> "rem"
    styleAttr = HP.attr (AttrName "style") ("opacity: " <> show opacity <> "; background-color: " <> bg <> "; width: " <> sizeStr <> "; height: " <> sizeStr <> ";")
  in
    div [ classes [ staticClass ] ]
      [ div [ classes [ dotClass ], styleAttr ] []
      , div [ classes [ dotClass ], styleAttr ] []
      , div [ classes [ dotClass ], styleAttr ] []
      ]
