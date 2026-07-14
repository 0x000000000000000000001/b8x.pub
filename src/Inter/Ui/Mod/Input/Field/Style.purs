module Inter.Ui.Mod.Input.Field.Style
  (class'
  , field
  , field_
  , staticClass
  , staticStyle
  , style
  ) where

import Proem hiding (top, div)

import CSS (borderColor, solid)
import CSS as CSS
import Color (cssStringRGBA)
import Data.Maybe (Maybe(..))
import DOM.HTML.Indexed (HTMLinput)
import Halogen.HTML (HTML, Leaf, input)
import Inter.Ui.Mod.Input.Type.State (State)
import Inter.Ui.Mod.Input.Util.Style (blue)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Color (lightGrey)
import Util.Style.Effect (borderBottomWidth, borderLeftWidth, borderRadiusRem1, borderRightWidth, borderStyle, borderTopWidth, outlineNone)
import Util.Style.Layout (boxSizingBorderBox, overflowHidden, padding4, widthPct100)
import Util.Style.Base (noCss, raw_)
import Util.Style.Selector (focus, placeholder, (.?), (:&))
import Util.Style.Typography (fontSizePct)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Input.Field.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    fontSizePct 100.0
    borderStyle solid
    padding4 1.6 0.7 0.8 0.7
    outlineNone
    borderRadiusRem1 0.2
    overflowHidden
    widthPct100
    boxSizingBorderBox
    raw_ "color-scheme" "light"

    focus :& do
      borderColor blue

style :: State -> CSS.CSS
style { id
  , input:
      { style:
          { backgroundColor: backgroundColor'
          , textColor
          , placeholderColor
          , border
          }
      }
  } = do
  class' id .? do
    case backgroundColor' of
      Just c -> raw_ "background-color" (cssStringRGBA c)
      Nothing -> noCss
    case border.color of
      Just c -> raw_ "border-color" (cssStringRGBA c)
      Nothing -> raw_ "border-color" (cssStringRGBA lightGrey)
    borderTopWidth $ border.width.top ??⇒ 0.0
    borderRightWidth $ border.width.right ??⇒ 0.0
    borderBottomWidth $ border.width.bottom ??⇒ 0.2
    borderLeftWidth $ border.width.left ??⇒ 0.0
    case textColor of
      Just c -> raw_ "color" (cssStringRGBA c)
      Nothing -> noCss

    placeholder :& do
      case placeholderColor of
        Just c -> raw_ "color" (cssStringRGBA c)
        Nothing -> noCss

field :: ∀ w i. InstanceId -> Leaf HTMLinput w i
field id props = input ([ classes [ staticClass, class' id ] ] <> props)

field_ :: ∀ w i. InstanceId -> HTML w i
field_ id = field id []
