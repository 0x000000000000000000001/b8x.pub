module Inter.Ui.Page.Article.Books.Author.Style
  ( author
  , author_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (Color, backgroundColor, borderColor, rgb, solid, white)
import CSS as CSS
import CSS.FontStyle (fontStyle, italic)
import CSS.Text (textDecoration, underline)
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Inter.Ui.Mod.Tooltip.Outer.Core.Style as TooltipCore
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass)
import Util.Style.Effect (borderRadiusPct50, borderStyle, borderWidth1, cursorPointer)
import Util.Style.Image (objectFitCover)
import Util.Style.Layout (displayInlineBlock, heightRem, marginBottom, marginTop, widthRem)
import Util.Style.Selector ((.?))
import Util.Style.Typography (textAlignCenter)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Books.Author.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

tooltipBackgroundColor :: Color
tooltipBackgroundColor = rgb 26 26 26

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayInlineBlock
    TooltipCore.staticClass .? do
      backgroundColor tooltipBackgroundColor
      textAlignCenter
    CSS.select (CSS.fromString ".tooltipPortrait") do
      textAlignCenter
      marginBottom 1.0
      CSS.select (CSS.fromString "img") do
        widthRem 9.375
        heightRem 9.375
        objectFitCover
        borderRadiusPct50
        borderWidth1 0.25
        borderStyle solid
        borderColor white
    CSS.select (CSS.fromString ".exploreArchives") do
      marginTop 1.0
      textAlignCenter
      cursorPointer
      textDecoration underline
      fontStyle italic

author :: ∀ w i. InstanceId -> Node HTMLdiv w i
author id props = div ([ classes [ staticClass, class' id ] ] <> props)

author_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
author_ id = author id []
