module Inter.Ui.Page.Article.Hero.Header.Author.Style
  ( class'
  , author
  , author_
  , staticClass
  , staticStyle
  ) where

import Proem

import CSS (color, rgba)
import CSS as CSS
import DOM.HTML.Indexed (HTMLh2)
import Halogen.HTML (HTML, Node, h2)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Base (raw)
import Util.Style.Selector ((.?))
import Util.Style.Layout (marginBottom, marginTop)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Typography (fontSizeRem, fontWeightBold)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Header.Author.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    fontSizeRem 1.5
    fontWeightBold
    color $ rgba 210 84 49 1.0
    raw "text-shadow" "0 0 0.5rem rgba(255,255,255,1.0), 0 0 1rem rgba(255,255,255,0.8)"
    marginTop 0.0
    marginBottom 0.0
    CSS.select (CSS.fromString ".authorLink") $ do
      raw "cursor" "pointer"
      raw "text-decoration" "underline"
    CSS.select (CSS.fromString ".tooltipPortrait") $ do
      raw "text-align" "center"
      marginBottom 1.0
      CSS.select (CSS.fromString "img") $ do
        raw "width" "150px"
        raw "height" "150px"
        raw "object-fit" "cover"
        raw "border-radius" "50%"
        raw "border" "4px solid white"
    CSS.select (CSS.fromString ".exploreArchives") $ do
      marginTop 1.0
      raw "text-align" "center"
      raw "cursor" "pointer"
      raw "text-decoration" "underline"
      raw "font-style" "italic"

author :: ∀ w i. InstanceId -> Node HTMLh2 w i
author id props = h2 ([ classes [ staticClass, class' id ] ] <> props)

author_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
author_ id = author id []
