module Inter.Ui.Router.Menu.Core.Items.Item.Item where

import Proem hiding (top, div)

import CSS (flex)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Halogen (ComponentHTML)
import Inter.Ui.Capability.Navigate.Navigate (Route)
import Inter.Ui.Mod.Link.Component (link_)
import Inter.Ui.Router.Menu.Core.Items.Item.Label.Label (label)
import Inter.Ui.Router.Menu.Core.Items.Item.Style.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.UiM (UiM)
import Halogen.HTML (div)
import Halogen.HTML.Events (onClick)
import Halogen.HTML.Properties (classes)
import Halogen.HTML.Core (ClassName(..))

item :: String -> Maybe Route -> Maybe Action -> ComponentHTML Action Slots UiM
item label' route mAction =
  case route of
    Just r -> 
      link_
        @"items"
        { route: Just r
        , classes: Just [ Style.staticClass ]
        , display: flex
        , children:
            [ label label'
            ]
        }
        HandleLinkOutput
        (label' /\ Just r)
    Nothing ->
      div
        ( [ classes [ ClassName Style.staticClass ] ] <> (mAction ?? (\a -> [ onClick \_ -> a ]) ⇔ []) )
        [ label label' ]
