module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.BooksAndAuthors.Style where

import Proem hiding (div)

import CSS (CSS, color, rgba)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, IProp, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (marginBottom)
import Util.Style.Typography (fontSizeRem)
import Util.Style.MediaQuery (onTabletLte)
import Util.Style.Selector ((.?))
import Util.Style.Base (raw_)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.BooksAndAuthors.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    fontSizeRem 0.95
    color $ rgba 0 0 0 0.6
    marginBottom 0.4

    onTabletLte do
      raw_ "grid-column" "1 / -1"

booksAndAuthors :: ∀ w i. Array (IProp HTMLdiv i) -> Array (HTML w i) -> HTML w i
booksAndAuthors props = div ([ class_ staticClass ] <> props)

booksAndAuthors_ :: ∀ w i. Array (HTML w i) -> HTML w i
booksAndAuthors_ = booksAndAuthors []
