module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.MatchingWord.Style
  (matchingWord
  , matchingWord_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (bottom, div, top, (?))

import CSS (backgroundColor, height, pct, rem, rgba, width, zIndex)
import CSS as CSS
import CSS.Size (calcSum)
import DOM.HTML.Indexed (HTMLspan)
import Halogen.HTML (HTML, Node, span)
import Util.Style.Anchor (centerToCenter)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Color (colorRed)
import Util.Style.Layout (displayInlineBlock)
import Util.Style.Position (positionAbsolute, positionRelative)
import Util.Style.Selector (after, (.?), (:&))
import Util.Style.Typography (content, fontWeightBold, textDecorationInherit)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.MatchingWord.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionRelative
    displayInlineBlock
    zIndex 0
    textDecorationInherit
    colorRed
    fontWeightBold

    after :& do
      content ""
      centerToCenter
      positionAbsolute
      width $ calcSum (pct 100.0) (rem 0.31)
      height $ calcSum (pct 100.0) (rem 0.04)
      backgroundColor (rgba 248 113 113 0.3)
      zIndex (-1)

matchingWord :: ∀ w i. Node HTMLspan w i
matchingWord props = span ([ class_ staticClass ] <> props)

matchingWord_ :: ∀ w i. Array (HTML w i) -> HTML w i
matchingWord_ = matchingWord []
