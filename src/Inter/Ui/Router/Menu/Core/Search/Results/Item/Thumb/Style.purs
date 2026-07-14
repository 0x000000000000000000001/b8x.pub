module Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style where

import Proem hiding (top, div)

import CSS (CSS, flexShrink)
import DOM.HTML.Indexed (HTMLimg)
import Halogen.HTML (HTML, IProp, img)
import Util.Style.Classname (classes, generateStaticClass, refineClass')
import Util.Style.Layout (heightRem, marginRight, maxWidthRem, widthAuto, widthRem)
import Util.Style.Effect (borderRadiusRem1)
import Util.Style.Selector ((.?))
import Util.Style.Image (objectFitCover)

data Format
  = Landscape
  | Square
  | Portrait

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticClassWhenLandscape :: String
staticClassWhenLandscape = refineClass' staticClass "landscape"

staticClassWhenSquare :: String
staticClassWhenSquare = refineClass' staticClass "square"

staticClassWhenPortrait :: String
staticClassWhenPortrait = refineClass' staticClass "portrait"

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    flexShrink 0.0
    marginRight 1.2
    borderRadiusRem1 0.4
    objectFitCover

  __landscape .? do
    widthAuto
    maxWidthRem 9.0
    heightRem 5.0

  __square .? do
    widthRem 6.0
    heightRem 6.0

  __portrait .? do
    widthAuto
    maxWidthRem 6.0
    heightRem 8.0

  where
  __landscape = staticClassWhenLandscape
  __square = staticClassWhenSquare
  __portrait = staticClassWhenPortrait

thumb :: ∀ w i. Format -> Array (IProp HTMLimg i) -> HTML w i
thumb format props = img ([ classes [ staticClass, classForFormat format ] ] <> props)
  where
  classForFormat = case _ of
    Landscape -> staticClassWhenLandscape
    Square -> staticClassWhenSquare
    Portrait -> staticClassWhenPortrait

thumb_ :: ∀ w i. Format -> HTML w i
thumb_ format = thumb format []
