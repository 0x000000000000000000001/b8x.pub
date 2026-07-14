module Inter.Ui.Mod.Tooltip.Tooltip
  ( tooltip
  ) where

import Proem hiding (div)

import Inter.Ui.Mod.Tooltip.Inner.Style (inner_)
import Inter.Ui.Mod.Tooltip.Outer.Core.Style (core_)
import Inter.Ui.Mod.Tooltip.Outer.Style.Style (outer)
import Inter.Ui.Mod.Tooltip.Style.Style (tooltip_)
import Inter.Ui.Mod.Tooltip.Type (Input)
import Inter.Ui.Type.Html (noHtml)
import Inter.Ui.UiM (UiM)
import Halogen (ComponentHTML)
import Halogen.HTML.CSS (style)
import Util.Style.Layout (padding1, padding2)
import Util.Style.Base (noCss)
import Data.Maybe (Maybe(..))
import Util.Style.Anchor (anchorPositionToCss)
import Util.Style.Size (applyToSize)
import CSS.Geometry (width)

tooltip
  :: ∀ action slots
   . Input action slots
  -> ComponentHTML action slots UiM
tooltip { disabled, inner, outer: outer', style: { offset, anchorPosition, width: w } } =
  tooltip_
    [ inner_ [ inner ]
    , disabled
        ? noHtml
        ↔ outer
            [ style do
                case offset of
                  Just { vertical, horizontal } -> padding2 vertical horizontal
                  Nothing -> padding1 1.0
                case anchorPosition of
                  Just pos -> anchorPositionToCss pos
                  Nothing -> noCss
                case w of
                  Just s -> applyToSize width s
                  Nothing -> noCss
            ]
            [ core_ [ outer' ] ]
    ]
