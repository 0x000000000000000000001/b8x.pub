module Inter.Ui.Page.Article.Hero.Header.Title.Style
  (class'
  , title
  , title_
  , staticClass
  , staticStyle
  ) where

import Proem

import CSS (color, rgba)
import CSS as CSS
import DOM.HTML.Indexed (HTMLh1)
import Halogen.HTML (HTML, Node, h1)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Base (raw)
import Util.Style.Selector ((.?))
import Util.Style.Layout (marginBottom, marginTop)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Typography (fontSizeRem, fontWeightBold, secondaryFont)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Header.Title.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    secondaryFont
    fontSizeRem 4.0
    fontWeightBold
    color $ rgba 97 17 15 1.0
    raw "text-shadow" "0 0 0.5rem rgba(255,255,255,1.0), 0 0 1rem rgba(255,255,255,0.8)"
    raw "line-height" "1.1"
    marginTop 0.0
    marginBottom 0.0

title :: ∀ w i. InstanceId -> Node HTMLh1 w i
title id props = h1 ([ classes [ staticClass, class' id ] ] <> props)

title_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
title_ id = title id []
