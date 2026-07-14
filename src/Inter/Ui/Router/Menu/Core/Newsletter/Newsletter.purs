module Inter.Ui.Router.Menu.Core.Newsletter.Newsletter where

import Halogen (ComponentHTML)
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Router.Menu.Type.State.Newsletter as NewsletterState
import Inter.Ui.Router.Menu.Core.Newsletter.Years.Years (years)
import Inter.Ui.Router.Menu.Core.Newsletter.Months.Months (months)
import Inter.Ui.Router.Menu.Core.Newsletter.Articles.Articles (articles)

newsletter :: State -> Array (ComponentHTML Action Slots UiM)
newsletter state =
  case state.newsletter.page of
      NewsletterState.Years -> years state
      NewsletterState.Months { year } -> months state year
      NewsletterState.Articles { year, month, fromShortcut } -> articles state year month fromShortcut
