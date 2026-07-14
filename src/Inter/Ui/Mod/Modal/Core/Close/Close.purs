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

close :: ∀ q i o. ComponentHTML (Action i o) (Slots q o) UiM
close =
  Style.close
    [ onClick $ κ $ HandleCloseClick ]
    [ render (SanitizedHtmlString closeSvg) ]

closeSvg :: String
closeSvg =
  """
<?xml version="1.0" encoding="utf-8"?><!-- Uploaded to: SVG Repo, www.svgrepo.com, Generator: SVG Repo Mixer Tools -->
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<circle cx="12" cy="12" r="10" stroke="#1C274C" stroke-width="1.5"/>
<path d="M14.5 9.50002L9.5 14.5M9.49998 9.5L14.5 14.5" stroke="#1C274C" stroke-width="1.5" stroke-linecap="round"/>
</svg>
"""
