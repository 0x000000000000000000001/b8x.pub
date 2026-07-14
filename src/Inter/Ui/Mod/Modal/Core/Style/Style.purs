module Inter.Ui.Mod.Modal.Core.Style.Style
  (core
  , core_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (classes, generateStaticClass)
import Util.Style.Color (backgroundColorWhite)
import Util.Style.Position (positionRelative)
import Util.Style.Layout (margin2, padding1, widthRem)
import Util.Style.Effect (borderRadiusRem1)
import Util.Style.Selector ((.?))

import Halogen.HTML.Properties as HP
import Halogen.HTML.Core (AttrName(..))
import Data.Maybe (Maybe(..))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Modal.Core.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName


staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionRelative
    backgroundColorWhite
    widthRem 60.0
    padding1 2.0
    borderRadiusRem1 0.5
    margin2 8.0 2.0

core :: ∀ w i. Maybe String -> Maybe Number -> Node HTMLdiv w i
core bgOpt widthRemOpt props =
  let
    bgStr = case bgOpt of
      Just bg -> "background-color: " <> bg <> ";"
      Nothing -> ""
    widthStr = case widthRemOpt of
      Just w -> "width: " <> show w <> "rem;"
      Nothing -> ""
    styleStr = bgStr <> widthStr
    styleAttr = HP.attr (AttrName "style") styleStr
  in
    div ([ classes [ staticClass ], styleAttr ] <> props)

core_ :: ∀ w i. Maybe String -> Maybe Number -> Array (HTML w i) -> HTML w i
core_ bgOpt widthRemOpt = core bgOpt widthRemOpt []