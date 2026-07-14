module Inter.Ui.Page.Article.Hero.Illustration.Caption.Style
  (class'
  , caption
  , caption_
  , staticClass
  , staticStyle
  ) where

import Proem

import CSS as CSS
import DOM.HTML.Indexed (HTMLfigcaption)
import Halogen.HTML (HTML, Node, figcaption)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Inter.Ui.Type.InstanceId (InstanceId)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Illustration.Caption.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = pure unit

caption :: ∀ w i. InstanceId -> Node HTMLfigcaption w i
caption id props = figcaption ([ classes [ staticClass, class' id ] ] <> props)

caption_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
caption_ id = caption id []
