module Inter.Ui.Mod.Input.HandleAction.Receive (receive) where

import Proem

import Halogen (get, modify_)
import Inter.Ui.Mod.Input.Type.Input (Input)
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.Type.Value (ControlledValue(..), When(..))
import Inter.Ui.Type.ControlledState as ControlledState

receive :: Input -> InputM Ɩ
receive input = do
  { value } <- get

  case value of
    ControlledState.Controlled _ ->
      case input.value of
        Controlled newVal ->
          modify_ _ { value = ControlledState.Controlled newVal }
        Uncontrolled Rightaway newVal ->
          modify_ _ { value = ControlledState.Uncontrolled newVal }
        Uncontrolled (OnceChanged _) newVal ->
          modify_ _ { value = ControlledState.Controlled newVal }

    _ -> ηι

  modify_ _ { input = input }
