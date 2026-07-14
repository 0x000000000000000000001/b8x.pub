module Inter.Ui.Mod.Tooltip.Style.Style
  ( staticClass
  , staticStyle
  , tooltip
  , tooltip_
  ) where

import Proem hiding (div, top)

import Inter.Ui.Mod.Tooltip.Outer.Style.Style as Outer
import CSS (hover)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import CSS as CSS
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Position (positionRelative)
import Util.Style.Layout (displayInlineBlock, displayNone)
import Util.Style.Selector ((.?), (.*), (:&))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Tooltip.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = staticClass .? do
  positionRelative

  Outer.staticClass .* do
    displayNone

  hover :& do
    Outer.staticClass .* do
      displayInlineBlock

tooltip :: ∀ w i. Node HTMLdiv w i
tooltip props = div ([ class_ staticClass ] <> props)

tooltip_ :: ∀ w i. Array (HTML w i) -> HTML w i
tooltip_ = tooltip []
