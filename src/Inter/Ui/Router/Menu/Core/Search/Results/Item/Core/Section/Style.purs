module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Section.Style where

import Proem hiding (div)

import CSS (CSS)
import CSS.Text.Transform (textTransform, uppercase)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (marginBottom)
import Util.Style.Typography (fontSizeRem, fontWeightBold, letterSpacingRem)
import Util.Style.Selector ((.?))

import Util.Style.Color (colorRed)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Section.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    fontWeightBold
    fontSizeRem 0.75
    marginBottom 0.4
    letterSpacingRem 0.05
    colorRed
    textTransform uppercase

section :: ∀ w i. Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
section props = div ([ class_ staticClass ] <> props)

section_ :: ∀ w i. Array (HTML w i) -> HTML w i
section_ = section []
