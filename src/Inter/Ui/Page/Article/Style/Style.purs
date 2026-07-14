module Inter.Ui.Page.Article.Style.Style
  (class'
  , articleContainer
  , articleContainer_
  , staticClass
  , staticStyle
  ) where

import Proem

import CSS (color, column, flexDirection, minHeight, rgba, vh)
import CSS as CSS
import DOM.HTML.Indexed (HTMLarticle)
import Halogen.HTML (HTML, Node, article)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Layout (displayFlex, widthPct)
import Util.Style.Selector ((.?))
import Inter.Ui.Type.InstanceId (InstanceId)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayFlex
    flexDirection column
    widthPct 100.0
    color $ rgba 51 51 51 1.0
    minHeight (vh 100.0)

articleContainer :: ∀ w i. InstanceId -> Node HTMLarticle w i
articleContainer id props = article ([ classes [ staticClass, class' id ] ] <> props)

articleContainer_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
articleContainer_ id = articleContainer id []
