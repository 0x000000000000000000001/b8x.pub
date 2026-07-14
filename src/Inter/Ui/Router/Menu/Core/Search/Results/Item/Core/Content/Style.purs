module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Style where

import Proem hiding (div)

import CSS (CSS, color, rgba)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Typography (fontSizeRem, lineHeightRem)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    color $ rgba 0 0 0 0.65
    fontSizeRem 0.95
    lineHeightRem 1.4

content :: ∀ w i. Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
content props = div ([ class_ staticClass ] <> props)

content_ :: ∀ w i. Array (HTML w i) -> HTML w i
content_ = content []
