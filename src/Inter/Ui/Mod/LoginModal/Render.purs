module Inter.Ui.Mod.LoginModal.Render where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Inter.Ui.Mod.LoginModal.Type (Action(..), Slots, State)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.Modal.Component (modal)
import Inter.Ui.Mod.Login.Component as Login
import Data.Maybe (Maybe(..))
import Halogen.HTML (text)

render :: State -> ComponentHTML Action Slots UiM
render s =
  if s.isOpen then
    modal Login.component { closable: true, open: true, background: Just "rgba(0,0,0,0.5)", widthRem: Just 50.0, innerInput: {} } HandleModalOutput
  else
    text ""
