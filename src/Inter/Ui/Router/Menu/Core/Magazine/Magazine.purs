module Inter.Ui.Router.Menu.Core.Magazine.Magazine where

import Halogen (ComponentHTML)
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Router.Menu.Type.State.Magazine as MagazineState
import Inter.Ui.Router.Menu.Core.Magazine.Years.Years (years)
import Inter.Ui.Router.Menu.Core.Magazine.Covers.Covers (covers)
import Inter.Ui.Router.Menu.Core.Magazine.Articles.Articles (articles)

magazine :: State -> Array (ComponentHTML Action Slots UiM)
magazine state =
  case state.magazine.page of
    MagazineState.Years -> years state
    MagazineState.Covers { year } -> covers state year
    MagazineState.Articles { year, slug } -> articles state year slug
