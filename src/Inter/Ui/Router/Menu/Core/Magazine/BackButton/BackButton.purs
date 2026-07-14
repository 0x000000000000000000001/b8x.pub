module Inter.Ui.Router.Menu.Core.Magazine.BackButton.BackButton where

import Proem

import Halogen (ComponentHTML)
import Halogen.HTML.Events (onClick)
import Halogen.HTML.CSS as Halogen.HTML.CSS
import Util.Style.Base as Util.Style.Base
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Core.Search.QuitButton.Style as Style
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)

backButton :: State -> Action -> Array (ComponentHTML Action Slots UiM) -> ComponentHTML Action Slots UiM
backButton state action children =
  Style.quitButton state
    [ onClick $ κ action
    ]
    children

backButtonDisabled :: State -> Array (ComponentHTML Action Slots UiM) -> ComponentHTML Action Slots UiM
backButtonDisabled state children =
  Style.quitButton state
    [ onClick $ κ DoNothing
    , Halogen.HTML.CSS.style (Util.Style.Base.raw "cursor" "not-allowed")
    ]
    children

