module Inter.Ui.Mod.Modal.Core.Close.Close
  ( close
  ) where

import Proem
import Halogen (ComponentHTML)
import Halogen.HTML.Events (onClick)
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..), render)
import Inter.Ui.Mod.Modal.Core.Close.Style as Style
import Inter.Ui.Mod.Modal.Type (Action(..), Slots)
import Inter.Ui.UiM (UiM)

import Inter.Ui.Mod.Icon.Close (closeSvg)

close :: ∀ q i o. ComponentHTML (Action i o) (Slots q o) UiM
close =
  Style.close
    [ onClick $ κ $ HandleCloseClick ]
    [ render (SanitizedHtmlString (closeSvg { stroke: "white", fill: "transparent" })) ]
