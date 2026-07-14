module Inter.Ui.Mod.PrettyErrorImage.Style.Style
  (class'
  , prettyErrorImage
  , prettyErrorImage_
  , staticClass
  , staticStyle
  , style
  ) where

import Proem hiding (div, top)

import CSS (backgroundColor, borderColor, height, hover, solid, width)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Mod.PrettyErrorImage.Type (State, Try(..))
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Color (lightGrey)
import Util.Style.Effect (borderRadius1, borderStyle, borderWidth1, defaultLoading)
import Util.Style.Layout (alignItemsCenter, displayFlex, justifyContentCenter, overflowHidden)
import Util.Style.Position (positionRelative)
import Util.Style.Base (noCss)
import Util.Style.Selector ((.?), (:&))
import Util.Style.Size (applyToSize)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.PrettyErrorImage.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionRelative
    borderStyle solid
    overflowHidden

style :: State -> CSS.CSS
style
  { id
  , try
  , input:
      { loading: loading'
      , style:
          { width: width'
          , height: height'
          , border
          , when:
              { errored:
                  { backgroundColor: backgroundColor'
                  }
              }
          , with:
              { hover:
                  { border: border'
                  }
              }
          }
      }
  } = do
  class' id .? do
    width' ?? (applyToSize width) ⇔ noCss
    height' ?? (applyToSize height) ⇔ noCss
    border.radius ?? (applyToSize borderRadius1) ⇔ noCss
    border.width ?? borderWidth1 ⇔ noCss
    border.color ?? borderColor ⇔ noCss

    when (try == StopTrying) do
      displayFlex
      justifyContentCenter
      alignItemsCenter
      backgroundColor $ backgroundColor' ??⇒ lightGrey

    when loading' do
      defaultLoading

    hover :& do
      border'.radius ?? (applyToSize borderRadius1) ⇔ noCss
      border'.width ?? borderWidth1 ⇔ noCss
      border'.color ?? borderColor ⇔ noCss

prettyErrorImage :: ∀ w i. InstanceId -> Node HTMLdiv w i
prettyErrorImage id props = div ([ classes [ staticClass, class' id ] ] <> props)

prettyErrorImage_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
prettyErrorImage_ id = prettyErrorImage id []
