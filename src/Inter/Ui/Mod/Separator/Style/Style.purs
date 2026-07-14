module Inter.Ui.Mod.Separator.Style.Style
  (separator
  , separator_
  , staticClass
  , staticClassWhenLoading
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (borderBottom, borderColor, rem, solid)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Mod.Separator.Text.Style as Text
import Inter.Ui.Mod.Separator.Util.Style (grey)
import Util.Lexicon.Loading (loading_)
import Util.Style.Classname (classes, generateStaticClass, refineClass')
import Util.Style.Color (backgroundColorWhite, lightGrey)
import Util.Style.Position (positionSticky, top0)
import Util.Style.Layout (alignItemsCenter, displayFlex, justifyContentCenter, padding4, widthPct100)
import Util.Style.Effect (defaultLoading)
import Util.Style.Selector ((.?), (.*))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Separator.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticClassWhenLoading :: String
staticClassWhenLoading = refineClass' staticClass loading_

zIndex :: Int
zIndex = 100

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayFlex
    justifyContentCenter
    alignItemsCenter
    widthPct100
    backgroundColorWhite
    positionSticky
    top0
    padding4 0.6 0.6 0.0 0.6
    borderBottom solid (rem 0.15) grey
    CSS.zIndex zIndex

  staticClassWhenLoading .? do
    borderColor lightGrey

    Text.staticClass .* do
      defaultLoading

separator :: ∀ w i. Boolean -> Node HTMLdiv w i
separator loading props = div ([ classes [ staticClass, loading ? staticClassWhenLoading ↔ "" ] ] <> props)

separator_ :: ∀ w i. Boolean -> Array (HTML w i) -> HTML w i
separator_ loading = separator loading []
