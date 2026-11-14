module Inter.Ui.Router.Menu.Core.CloseButton.CloseButton
  ( closeButton
  ) where

import Proem
import Halogen (ComponentHTML)
import Halogen.HTML.Events (onClick)
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..), render)
import Inter.Ui.Router.Menu.Core.CloseButton.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)

import Inter.Ui.Mod.Icon.Close (closeSvg)

closeButton :: State -> ComponentHTML Action Slots UiM
closeButton _ =
  Style.closeButton
    [ onClick $ κ $ Close ]
    [ render (SanitizedHtmlString (closeSvg { stroke: "#888888", fill: "transparent" })) ]
