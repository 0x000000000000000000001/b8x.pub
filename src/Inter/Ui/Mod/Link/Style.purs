module Inter.Ui.Mod.Link.Style
  (class'
  , link
  , link_
  , staticClass
  , staticStyle
  , style
  , sheet
  ) where

import Proem hiding (top)

import CSS (display, noneTextDecoration, textDecoration)
import CSS as CSS
import DOM.HTML.Indexed (HTMLa)
import Halogen.HTML (HTML, Node, a)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Mod.Link.Type (State)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, inferInstanceClass, generateStaticClass)
import Util.Style.Effect (cursorPointer)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Link.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    textDecoration noneTextDecoration
    cursorPointer

style :: State -> CSS.CSS
style { id, input: { display: display_ } } = do
  class' id .? do
    display display_

sheet :: ∀ w i. State -> HTML w i
sheet s = stylesheet do
  style s

link :: ∀ w i. InstanceId -> Array String -> Node HTMLa w i
link id classes' props = a ([ classes $ [ staticClass, class' id ] <> classes' ] <> props)

link_ :: ∀ w i. InstanceId -> Array String -> Array (HTML w i) -> HTML w i
link_ id classes' = link id classes' []
