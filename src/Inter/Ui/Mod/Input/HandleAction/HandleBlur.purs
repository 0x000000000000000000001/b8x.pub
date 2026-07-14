module Inter.Ui.Mod.Input.HandleAction.HandleBlur (handleBlur) where

import Proem

import Halogen (modify_, raise)
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.Type.Output (Output(..))

handleBlur :: InputM Ɩ
handleBlur = do
  modify_ _ { focused = false }

  raise Blurred
