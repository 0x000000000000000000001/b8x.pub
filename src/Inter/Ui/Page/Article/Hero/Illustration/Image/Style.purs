module Inter.Ui.Page.Article.Hero.Illustration.Image.Style
  (class'
  , image
  , image_
  , staticClass
  , staticStyle
  ) where

import Proem

import CSS as CSS
import DOM.HTML.Indexed (HTMLimg)
import Halogen.HTML (HTML, img, IProp)
import Inter.Ui.Router.PrettyBackground.Firefly.Style.Satellite as FireflySatellite
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Effect (borderRadiusRem1)
import Util.Style.Layout (maxHeightRem, maxWidthRem)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Illustration.Image.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticClassWhenPortrait :: String
staticClassWhenPortrait = refineClass' staticClass "portrait"

staticClassWhenLandscape :: String
staticClassWhenLandscape = refineClass' staticClass "landscape"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    borderRadiusRem1 1.0

  staticClassWhenPortrait .? do
    maxHeightRem 40.0

  staticClassWhenLandscape .? do
    maxHeightRem 45.0
    maxWidthRem 60.0

image :: ∀ w i. InstanceId -> Boolean -> Array (IProp HTMLimg i) -> HTML w i
image id isPortrait props = img ([ classes [ staticClass, FireflySatellite.staticClass, if isPortrait then staticClassWhenPortrait else staticClassWhenLandscape, class' id ] ] <> props)

image_ :: ∀ w i. InstanceId -> Boolean -> HTML w i
image_ id isPortrait = image id isPortrait []
