module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.Style.Style
  (textWithMatchingWords
  , textWithMatchingWords_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (bottom, div, top, (?))

import CSS as CSS
import DOM.HTML.Indexed (HTMLspan)
import Halogen.HTML (HTML, Node, span)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    ηι

textWithMatchingWords :: ∀ w i. Node HTMLspan w i
textWithMatchingWords props = span ([ class_ staticClass ] <> props)

textWithMatchingWords_ :: ∀ w i. Array (HTML w i) -> HTML w i
textWithMatchingWords_ = textWithMatchingWords []
