module Inter.Ui.Router.Menu.HandleAction.CloseNewsletter where

import Proem

import Data.Lens ((.~))
import Halogen (modify_)

import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.State.State (_activePanel)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))

import Inter.Ui.Type.IntentOrigin (IntentOrigin)
import Inter.Ui.Type.ControlledState (_Controlled, _Uncontrolled, shouldUseControlledPrism)
import Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu)

closeNewsletter :: IntentOrigin -> MenuM Ɩ
closeNewsletter intent = do
  useControlledPrism <- shouldUseControlledPrism intent _activePanel

  modify_ (_activePanel ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ None)
  
  scrollTopMenu
