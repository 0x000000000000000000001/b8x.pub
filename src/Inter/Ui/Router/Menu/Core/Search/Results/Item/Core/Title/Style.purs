module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Style where

import Proem hiding (div)

import CSS (CSS, color, rgba)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (marginBottom)
import Util.Style.Typography (fontSizeRem, fontWeightBold, lineHeightRem)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    fontWeightBold
    fontSizeRem 1.1
    marginBottom 0.4
    color $ rgba 0 0 0 0.85
    lineHeightRem 1.3

title :: ∀ w i. Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
title props = div ([ class_ staticClass ] <> props)

title_ :: ∀ w i. Array (HTML w i) -> HTML w i
title_ = title []
