module Inter.Ui.Mod.Separator.Text.Style
  (staticClass
  , staticStyle
  , text
  , text_
  ) where

import Proem hiding (div, top)

import Inter.Ui.Mod.Separator.Util.Style (grey)
import CSS (borderLeft, borderRight, borderTop, color, darken, fontFamily, rem, sansSerif, solid)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import CSS as CSS
import Data.NonEmpty ((:|))
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Position (positionRelative)
import Util.Style.Layout (displayInlineBlock, margin0, padding1)
import Util.Style.Typography (fontSizePct, fontWeightBold)
import Util.Style.Effect (borderRadiusRem4)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Separator.Text.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayInlineBlock
    margin0
    positionRelative
    borderLeft solid (rem 0.15) grey
    borderTop solid (rem 0.15) grey
    borderRight solid (rem 0.15) grey
    borderRadiusRem4 0.5 0.5 0.0 0.0
    padding1 0.6
    color $ darken 0.15 grey
    fontWeightBold
    fontSizePct 110.0
    fontFamily [ "Oswald" ] (sansSerif :| [])

text :: ∀ w i. Node HTMLdiv w i
text props = div ([ class_ staticClass ] <> props)

text_ :: ∀ w i. Array (HTML w i) -> HTML w i
text_ = text []