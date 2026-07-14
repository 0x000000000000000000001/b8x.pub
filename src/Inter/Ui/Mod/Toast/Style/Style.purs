module Inter.Ui.Mod.Toast.Style.Style where

import Proem hiding (div, top)

import CSS (color, px, rgba)
import Data.Tuple (Tuple)
import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Halogen.HTML.Elements.Keyed as HK
import Halogen.HTML.Properties as HP
import Halogen as H
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Layout (displayFlex)
import Util.Style.Position (positionFixed)
import Util.Style.Selector ((.?))
import Inter.Ui.Mod.Toast.Type (ToastStatus(..))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Toast.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticStyle :: CSS.CSS
staticStyle = do
  itemStyle
  itemEnteringStyle
  itemExitingStyle
  staticClass .? do
    positionFixed
    CSS.top $ px 16.0
    CSS.right $ px 16.0
    CSS.zIndex 9999
    displayFlex
    CSS.key (CSS.fromString "flex-direction") "column"
    CSS.key (CSS.fromString "align-items") "flex-end"
    CSS.key (CSS.fromString "gap") "8px"
    -- pointer-events-none is usually set to let clicks pass through the container
    CSS.key (CSS.fromString "pointer-events") "none"

toastContainer :: ∀ w i. Node HTMLdiv w i
toastContainer props = div ([ class_ staticClass ] <> props)

toastContainer_ :: ∀ w i. Array (HTML w i) -> HTML w i
toastContainer_ = toastContainer []

toastContainerKeyed :: ∀ w i. Array (Tuple String (HTML w i)) -> HTML w i
toastContainerKeyed = HK.div [ class_ staticClass ]

-- Styles for the Toast item itself
itemClass :: String
itemClass = generateStaticClass (fullModuleName <> ".Item")

itemStyle :: CSS.CSS
itemStyle = do
  itemClass .? do
    CSS.key (CSS.fromString "pointer-events") "auto"
    CSS.key (CSS.fromString "cursor") "pointer"
    CSS.padding (px 16.0) (px 16.0) (px 16.0) (px 16.0)
    CSS.borderRadius (px 4.0) (px 4.0) (px 4.0) (px 4.0)
    CSS.key (CSS.fromString "box-shadow") "0 4px 12px rgba(0,0,0,0.15)"
    color $ rgba 255 255 255 1.0
    CSS.key (CSS.fromString "transition") "all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)"
    CSS.key (CSS.fromString "max-height") "150px"
    CSS.key (CSS.fromString "opacity") "1"
    CSS.key (CSS.fromString "transform") "translateY(0)"
    CSS.key (CSS.fromString "margin-bottom") "0px"
    CSS.key (CSS.fromString "overflow") "hidden"
    CSS.key (CSS.fromString "font-family") "sans-serif"

itemEnteringClass :: String
itemEnteringClass = generateStaticClass (fullModuleName <> ".ItemEntering")

itemEnteringStyle :: CSS.CSS
itemEnteringStyle = do
  itemEnteringClass .? do
    CSS.key (CSS.fromString "transform") "translateY(-20px) !important"
    CSS.key (CSS.fromString "opacity") "0 !important"
    CSS.key (CSS.fromString "max-height") "0px !important"
    CSS.key (CSS.fromString "padding-top") "0px !important"
    CSS.key (CSS.fromString "padding-bottom") "0px !important"
    CSS.key (CSS.fromString "margin-top") "0px !important"
    CSS.key (CSS.fromString "margin-bottom") "-8px !important"

itemExitingClass :: String
itemExitingClass = generateStaticClass (fullModuleName <> ".ItemExiting")

itemExitingStyle :: CSS.CSS
itemExitingStyle = do
  itemExitingClass .? do
    CSS.key (CSS.fromString "transform") "translateX(120%) !important"
    CSS.key (CSS.fromString "opacity") "0 !important"
    CSS.key (CSS.fromString "max-height") "0px !important"
    CSS.key (CSS.fromString "padding-top") "0px !important"
    CSS.key (CSS.fromString "padding-bottom") "0px !important"
    CSS.key (CSS.fromString "margin-top") "0px !important"
    CSS.key (CSS.fromString "margin-bottom") "-8px !important"

toastItem :: ∀ w i. String -> ToastStatus -> Node HTMLdiv w i
toastItem bg status props =
  let
    classes = case status of
      Entering -> [ class_ itemClass, class_ itemEnteringClass ]
      Active -> [ class_ itemClass ]
      Exiting -> [ class_ itemClass, class_ itemExitingClass ]
  in
    div (classes <> [ HP.attr (H.AttrName "style") ("background-color: " <> bg) ] <> props)
