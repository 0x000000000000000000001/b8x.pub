module Inter.Ui.Router.Menu.HandleAction.OpenNewsletter where

import Proem

import Data.Lens ((.~))
import Halogen (modify_)

import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.State.State (_newsletter, _activePanel)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Router.Menu.Type.State.Newsletter as Newsletter
import Inter.Ui.Remote (queryModify)
import Inter.Ui.Router.Menu.Type.State.Newsletter (_calendar, _page)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Query (GetNewsletterCalendar(..))
import Inter.Ui.Type.IntentOrigin (IntentOrigin)
import Inter.Ui.Type.ControlledState (_Controlled, _Uncontrolled, shouldUseControlledPrism)
import Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu)

openNewsletter :: IntentOrigin -> MenuM Ɩ
openNewsletter intent = do
  useControlledPrism <- shouldUseControlledPrism intent _activePanel

  modify_ (_activePanel ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ Newsletters)

  modify_ (_newsletter ◁ _page .~ Newsletter.Years)
  scrollTopMenu
  ø $ queryModify κηι (_newsletter ◁ _calendar) $ GetNewsletterCalendar {}
