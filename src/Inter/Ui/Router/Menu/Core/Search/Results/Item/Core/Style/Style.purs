module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Style where

import Proem hiding (div)

import CSS (CSS, column, flexDirection)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (displayFlex)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    displayFlex
    flexDirection column

core :: ∀ w i. Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
core props = div ([ class_ staticClass ] <> props)

core_ :: ∀ w i. Array (HTML w i) -> HTML w i
core_ = core []
