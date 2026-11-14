module Inter.Ui.Router.Menu.Core.Search.AuthorFilter.Style where

import Proem hiding (top, div)

import CSS as CSS
import CSS.Common (center)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.MediaQuery (onTabletLte)
import Util.Style.Base (raw_)
import Util.Style.Selector ((.?), (.*), (¨&))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.AuthorFilter.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    CSS.display CSS.flex
    CSS.alignItems center
    CSS.backgroundColor (CSS.rgba 230 240 255 1.0)
    CSS.color (CSS.rgba 0 50 150 1.0)
    CSS.padding (CSS.rem 0.3) (CSS.rem 0.6) (CSS.rem 0.3) (CSS.rem 0.6)
    CSS.borderRadius (CSS.rem 0.3) (CSS.rem 0.3) (CSS.rem 0.3) (CSS.rem 0.3)
    CSS.key (CSS.fromString "margin-left") "auto"
    CSS.marginRight (CSS.rem 0.5)

    ".texts" .* do
      CSS.display CSS.flex
      CSS.flexDirection CSS.column
      CSS.alignItems CSS.flexEnd
      raw_ "line-height" "1.2"
      CSS.fontSize (CSS.rem 0.75)

    onTabletLte do
      ".texts" .* do
        CSS.fontSize (CSS.rem 0.65)

    "closeIcon" .* do
      CSS.marginLeft (CSS.rem 0.8)
      CSS.fontSize (CSS.rem 1.1)
      CSS.opacity 0.6
      CSS.key (CSS.fromString "cursor") "pointer"
      CSS.display CSS.flex
      CSS.alignItems center

      ":hover" ¨& do
        CSS.opacity 1.0

authorFilterNode :: ∀ w i. Node HTMLdiv w i
authorFilterNode props = div ([ class_ staticClass ] <> props)

authorFilterNode_ :: ∀ w i. Array (HTML w i) -> HTML w i
authorFilterNode_ = authorFilterNode []
