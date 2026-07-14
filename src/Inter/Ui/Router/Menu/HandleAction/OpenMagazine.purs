module Inter.Ui.Router.Menu.HandleAction.OpenMagazine where

import Proem

import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Query (GetMagazineCalendar(..))
import Data.Lens ((.~))
import Halogen (modify_, raise)

import Inter.Ui.Remote (queryModify)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Router.Menu.Type.State.Magazine (_calendar, _page)
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine
import Inter.Ui.Router.Menu.Type.State.State (_magazine, _activePanel)
import Inter.Ui.Router.Menu.Type.Output as MenuOutput
import Inter.Ui.Type.ControlledState (_Controlled, _Uncontrolled, shouldUseControlledPrism)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu)

openMagazine :: IntentOrigin -> MenuM Ɩ
openMagazine intent = do
  useControlledPrism <- shouldUseControlledPrism intent _activePanel

  modify_ (_activePanel ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ Magazines)

  modify_ (_magazine ◁ _page .~ Magazine.Years)

  when (intent == Internal) $ raise MenuOutput.MagazineIssueClosed

  scrollTopMenu

  ø $ queryModify κηι (_magazine ◁ _calendar) $ GetMagazineCalendar {}
