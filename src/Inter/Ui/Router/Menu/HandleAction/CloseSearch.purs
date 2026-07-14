module Inter.Ui.Router.Menu.HandleAction.CloseSearch (closeSearch) where

import Proem

import Data.Lens ((.~))
import Halogen (modify_, raise)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Output (Output(..))
import Inter.Ui.Router.Menu.Type.State.State (_activePanel)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Type.ControlledState (_Controlled, _Uncontrolled, shouldUseControlledPrism)

closeSearch :: IntentOrigin -> MenuM Ɩ
closeSearch intent = do
  useControlledPrism <- shouldUseControlledPrism intent _activePanel

  modify_ (_activePanel ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ None)

  when (intent == Internal) $ raise SearchClosed
