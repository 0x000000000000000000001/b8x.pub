module Inter.Ui.Router.Menu.HandleAction.Close (close) where

import Proem

import Data.Lens ((.~))
import Halogen (modify_, raise)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Output (Output(..))
import Inter.Ui.Router.Menu.Type.State.State (_open)
import Inter.Ui.Type.ControlledState (_Controlled, _Uncontrolled, shouldUseControlledPrism)

close :: IntentOrigin -> MenuM Ɩ
close intent = do
  useControlledPrism <- shouldUseControlledPrism intent _open

  modify_ (_open ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ false)

  when (intent == Internal) $ raise Closed
