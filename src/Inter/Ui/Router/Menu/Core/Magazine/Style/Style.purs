module Inter.Ui.Router.Menu.Core.Magazine.Style.Style where

import Proem hiding (div, bottom, top)

import CSS (CSS, absolute, background, block, bold, bottom, color, column, display, flexDirection, fontSize, fontWeight, grid, hover, left, marginBottom, marginTop, opacity, padding, position, relative, rem, rgba, right, top)
import CSS.TextAlign (textAlign, center)
import CSS.Transition (ease)
import CSS.Time (sec)
import Halogen.HTML (HTML, div)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Image (objectFitCover)
import Util.Style.Layout (alignItemsCenter, displayFlex, flexGrow1, gapRem, gridTemplateColumns, heightPct100, justifyContentCenter, overflowHidden, overflowXHidden, overflowYAuto, widthPct100)
import Util.Style.Effect (cursorPointer)
import Util.Style.Transition (transitions)
import Util.Style.Transition as Transition
import Util.Style.Selector ((.?), (.*), (:&))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Magazine.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

itemsClass :: String
itemsClass = refineClass' staticClass "items"

mosaicClass :: String
mosaicClass = refineClass' staticClass "mosaic"

mosaicItemClass :: String
mosaicItemClass = refineClass' staticClass "mosaicItem"

mosaicItemImageClass :: String
mosaicItemImageClass = refineClass' staticClass "mosaicItemImage"

mosaicItemOverlayClass :: String
mosaicItemOverlayClass = refineClass' staticClass "mosaicItemOverlay"

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  itemsClass .? do
    widthPct100
    flexGrow1
    overflowXHidden
    overflowYAuto

  mosaicClass .? do
    display grid
    gridTemplateColumns "repeat(3, minmax(0, 1fr))"
    gapRem 1.0
    widthPct100
    flexGrow1
    overflowXHidden
    overflowYAuto
    marginTop (rem 1.5)
    marginBottom (rem 2.0)

  mosaicItemClass .? do
    widthPct100
    position relative
    overflowHidden
    cursorPointer

    hover :& do
      mosaicItemOverlayClass .* do
        opacity 1.0

  mosaicItemImageClass .? do
    display block
    widthPct100
    heightPct100
    objectFitCover
    position absolute
    left (rem 0.0)
    top (rem 0.0)

  mosaicItemOverlayClass .? do
    position absolute
    left (rem 0.0)
    right (rem 0.0)
    bottom (rem 0.0)
    top (rem 0.0)
    displayFlex
    flexDirection column
    justifyContentCenter
    alignItemsCenter
    padding (rem 1.0) (rem 1.0) (rem 1.0) (rem 1.0)
    background (rgba 0 0 0 0.85)
    color (rgba 255 255 255 1.0)
    opacity 0.0
    textAlign center
    transitions [ Transition.opacity (sec 0.2) ease (sec 0.0) ]

    ".title" .? do
      fontSize (rem 1.4)
      fontWeight bold
      marginBottom (rem 0.5)

    ".number" .? do
      fontSize (rem 1.2)
      marginBottom (rem 0.5)
      color (rgba 255 255 255 0.8)

    ".date" .? do
      fontSize (rem 1.1)
      color (rgba 255 255 255 0.7)

items_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
items_ id = div [ classes [ itemsClass, class' id ] ]

mosaic_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
mosaic_ id = div [ classes [ mosaicClass, class' id ] ]
