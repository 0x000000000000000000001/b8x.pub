module Inter.Ui.Mod.PrettyErrorImage.Image.Style
  (class'
  , image
  , image_
  , staticClass
  , staticStyle
  , style
  )
  where

import Proem hiding (top)

import CSS (opacity)
import CSS as CSS
import DOM.HTML.Indexed (HTMLimg)
import Halogen.HTML (HTML, Leaf, img)
import Inter.Ui.Mod.PrettyErrorImage.Type (State)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Image (fill, objectFit)
import Util.Style.Classname (classes, inferInstanceClass, generateStaticClass)
import Util.Style.Layout (heightPct100, widthPct100)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.PrettyErrorImage.Image.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    widthPct100
    heightPct100

style :: State -> CSS.CSS
style
  { id
  , input:
      { loading: loading'
      , style:
          { fit
          }
      }
  } = do
  class' id .? do
    objectFit $ fit ??⇒ fill

    when loading' do
      opacity 0.0

image :: ∀ w i. InstanceId -> Leaf HTMLimg w i
image id props = img ([ classes [ staticClass, class' id ] ] <> props)

image_ :: ∀ w i. InstanceId -> HTML w i
image_ id = image id []