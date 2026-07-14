module Inter.Ui.Mod.AdPlaceholder.Style.Style where

import Proem hiding (div)

import CSS (backgroundColor, color, display, flex, alignItems, justifyContent, width, height)
import CSS.Common (center)
import Halogen.HTML (HTML, div)
import Halogen.HTML.CSS (style)
import Util.Style.Size (Size)
import Util.Style.Size as Size
import Util.Style.Color (lightGrey)
import Color (darken)

adPlaceholder_ :: ∀ p i. Size -> Size -> Array (HTML p i) -> HTML p i
adPlaceholder_ w h =
  div
    [ style do
        display flex
        alignItems center
        justifyContent center
        backgroundColor lightGrey
        color (darken 0.5 lightGrey)
        Size.applyToSize width w
        Size.applyToSize height h
    ]
