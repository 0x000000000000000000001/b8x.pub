module Inter.Ui.Mod.Loader.Animation.Style where

import Proem hiding (div, top)

import CSS (Color, borderRight, borderTop, deg, forwards, fromString, infinite, keyframes, linear, normalAnimationDirection, rem, rotate, sec, solid, transform)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Data.NonEmpty ((:|))
import Data.Tuple.Nested ((/\))
import Halogen.HTML (HTML, IProp, div)
import Util.Lexicon.Color (color_)
import Util.Style.Classname (classes, inferAnimationId, refineClass, generateStaticClass)
import Util.Style.Color (transparent)
import Util.Style.Layout (displayInlineBlock, heightRem, widthRem)
import Util.Style.Effect (borderRadiusPct50)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Loader.Animation.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

classWithColor :: Color -> String
classWithColor color = refineClass staticClass color_ $ show color

animationId :: String
animationId = inferAnimationId staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    widthRem 3.0
    heightRem 3.0
    borderRadiusPct50
    displayInlineBlock
    borderRight solid (rem 0.4) transparent

    CSS.animation
      (fromString animationId)
      (sec 0.5)
      linear
      (sec 0.0)
      infinite
      normalAnimationDirection
      forwards

  keyframes animationId
    ((0.0 /\ (transform $ rotate $ deg 0.0))
        :| [ 100.0 /\ (transform $ rotate $ deg 360.0) ]
    )

style :: Color -> CSS.CSS
style color = do
  classWithColor color .? do
    borderTop solid (rem 0.4) color

animation :: ∀ w i. Color -> Array (IProp HTMLdiv i) -> HTML w i
animation color props = div ([ classes [ staticClass, classWithColor color ] ] <> props) []

animation_ :: ∀ w i. Color -> HTML w i
animation_ color = animation color []
