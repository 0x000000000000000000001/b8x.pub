module Inter.Ui.Mod.Input.HandleAction.HandleFocus (handleFocus) where

import Proem

import Halogen (modify_, raise)
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.Type.Output (Output(..))

handleFocus :: InputM Ɩ
handleFocus = do
  modify_ _ { focused = true }

  raise Focused
