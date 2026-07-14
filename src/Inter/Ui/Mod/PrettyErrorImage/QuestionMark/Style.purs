module Inter.Ui.Mod.PrettyErrorImage.QuestionMark.Style
  (class'
  , questionMark
  , questionMark_
  , staticClass
  , staticStyle
  , style
  ) where

import Proem hiding (top, div)

import CSS (darken, opacity, width)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML.Elements (div)
import Halogen.HTML (HTML, IProp)
import Inter.Ui.Mod.PrettyErrorImage.Type (State)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Color (lightGrey)
import Util.Style.Effect (fill)
import Util.Style.Base (noCss)
import Util.Style.Selector (svg, (.?), (:<))
import Util.Style.Size (Size(..), applyToSize)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.PrettyErrorImage.QuestionMark.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    noCss

style :: State -> CSS.CSS
style
  { id
  , input:
      { loading
      , style:
          { questionMark:
              { width: width'
              }
          , when:
              { errored:
                  { questionMark:
                      { color }
                  }
              }
          }
      }
  } = do
  class' id .? do
    applyToSize width $ width' ??⇒ (Rem 3.0)

    when loading do
      opacity 0.0

    svg :< do
      fill $ color ??⇒ darken 0.4 lightGrey

questionMark :: ∀ w i. InstanceId -> Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
questionMark id props = div ([ classes [ staticClass, class' id ] ] <> props)

questionMark_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
questionMark_ id = questionMark id []
