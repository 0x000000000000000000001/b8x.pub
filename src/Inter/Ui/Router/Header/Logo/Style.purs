module Inter.Ui.Router.Header.Logo.Style
  ( logo
  , logo_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (top, div)

import CSS (alignSelf, animation, ease, forwards, fromString, infinite, keyframes, normalAnimationDirection, sec)
import CSS as CSS
import CSS.Common (center)
import DOM.HTML.Indexed (HTMLimg)
import Data.NonEmpty ((:|))
import Data.Tuple.Nested ((/\))
import Halogen.HTML (HTML, Leaf, img)
import CSS.Transform (transforms, scale)
import Util.Style.Classname (class_, generateStaticClass, inferAnimationId)
import Util.Style.Layout (heightRem, margin4)
import Util.Style.Effect (cursorPointer)
import Util.Power (isPowerful)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Header.Logo.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

animationId :: String
animationId = inferAnimationId staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    heightRem 8.4
    margin4 1.7 1.0 1.0 1.0
    cursorPointer
    alignSelf center

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
